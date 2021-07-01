#!/bin/bash

proj_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && cd .. && pwd)"

REMOTE_DIR='~/final_project'

HOST=b7902143@cad29.ee.ntu.edu.tw

# Reuse connection
SOCKET='/tmp/ssh.sock'

# Kill connection on exit
# negative pid specifies process group
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# arguments
cycle_from=3
cycle_to=4
cycle_step=0.1
while [[ "$1" ]]; do
    case $1 in
        -rtl)
            # RTL simulation
            opt_rtl=1
            ;;
        -syn)
            # Synthesis
            opt_syn=1
            ;;
        -gate)
            # Gate-level simulation
            opt_gate=1
            ;;
        -hazard)
            # With hazard
            opt_hazard=1
            ;;
        -nohazard)
            # Without hazard
            opt_nohazard=1
            ;;
        -brpred)
            # with branch predictor
            opt_brpred=1
            ;;
        -l2)
            # with L2 cache
            opt_l2=1
            ;;
        -muldiv)
            # with multiplier and divider
            opt_muldiv=1
            ;;
        *)
            # clock cycle
            cycle_from="$1"
            cycle_to="$2"
            cycle_step="$3"
            shift 3
            ;;
    esac

    shift
done


# Create connection
ssh -N \
    -o 'ControlMaster=yes' \
    -o "ControlPath=$SOCKET" \
    "$HOST" &

# Upload only updated files
rsync \
    -e "ssh -S '$SOCKET'" \
    --archive --verbose --compress --update --progress --human-readable \
    "$proj_root/lib" \
    "$proj_root/src" \
    "$proj_root/syn" \
    "$proj_root/include" \
    "$proj_root/test" \
    "$HOST:$REMOTE_DIR/"
rsync \
    -e "ssh -S '$SOCKET'" \
    --archive --verbose --compress --update --progress --human-readable \
    "$proj_root/netlist/CHIP_syn."* \
    "$proj_root/syn/.synopsys_dc.setup" \
    "$proj_root/test/baseline/pattern/" \
    "$proj_root/test/brPred/pattern/" \
    "$proj_root/test/l2cache/pattern/" \
    "$proj_root/test/mulDiv/pattern/" \
    "$HOST:$REMOTE_DIR/"


# compile macro definition
defines=

if (( opt_hazard )); then
    defines="$defines +define+hasHazard"

elif (( opt_nohazard )); then
    defines="$defines +define+noHazard"

elif (( opt_brpred )); then
    defines="$defines +define+BrPred"

elif (( opt_l2 )); then
    defines="$defines +define+L2Cache"

elif (( opt_muldiv )); then
    defines="$defines +define+MultDiv"

fi


# Simulate RTL
if (( opt_rtl )); then
    ssh -S "$SOCKET" "$HOST" "
        cd $REMOTE_DIR
        rm -rf INCA_libs
        source /usr/cad/cadence/cshrc
        ncverilog \
            test/baseline/testbench/Final_tb.v \
            src/CHIP.v \
            src/cache_controller.v \
            src/cache_sram_2way.v \
            src/MIPS_Pipeline.v \
            src/PC.v \
            src/Control.v \
            src/RegFile.v \
            src/Forward.v \
            src/HazardDetect.v \
            src/ALU.v \
            src/StallControl.v \
            src/BrPred_local_1bit.v \
            src/BrPred_local_2bit.v \
            src/BrPred_global_1bit.v \
            src/BrPred_global_2bit.v \
            src/BrPred_corr.v \
            src/BrPred_BTB.v \
            lib/slow_memory.v \
            +incdir+test/baseline/testbench \
            +incdir+test/brPred/testbench \
            +incdir+test/l2cache/testbench \
            +incdir+test/mulDiv/testbench \
            +incdir+include \
            +incdir+src \
            $defines +access+r
    " | tee rtl.log
fi

# Synthesize
if (( opt_syn )); then
    pids=()
    cycle_seq=($(seq $cycle_from $cycle_step $cycle_to))

    for i in $(seq 0 ${#cycle_seq[@]}); do
        cycle=${cycle_seq[i]}
        if [[ ! "$cycle" ]]; then
            continue
        fi
        echo Synthesizing with cycle time $cycle
        (
            mkdir -pv netlist/syn_$cycle
            cd netlist/syn_$cycle

            ssh -S "$SOCKET" "$HOST" "
                cd $REMOTE_DIR
                mkdir syn_$cycle
                cd syn_$cycle
                cp ../.synopsys_dc.setup .
                source /usr/cad/synopsys/CIC/synthesis.cshrc
                design_vision -no_gui -x ' \\
                    set cycle $cycle \\
                    source ../syn/CHIP_syn.sdc'
            " | tee syn.log

            # Download gate-level verilog
            rsync -e "ssh -S '$SOCKET'" \
                --archive --verbose --compress --progress --human-readable \
                "$HOST":"$REMOTE_DIR/syn_$cycle/CHIP_syn.{v,sdf,ddc}" \
                ./

            area="$(sed -En 's/^ *Total cell area: *([0-9.]+)$/\1/p' < syn.log)"
            time="$(sed -En 's/^ *data arrival time *([0-9.]+)$/\1/p' < syn.log)"
            at=$(echo "$area * $time" | bc)

            if grep 'slack (MET)' < syn.log > /dev/null; then
                status=met
            else
                status=violated
            fi

            cd ..
            mv syn_$cycle syn_${at}_${area}_${time}_${status}
        ) & pids[i]=$!
    done

    for pid in "${pids[@]}"; do
        echo Wating for $pid
        wait $pid
    done
fi

# Post-synthesis simulation
if (( opt_gate )); then
    ssh -S "$SOCKET" "$HOST" "
        cd $REMOTE_DIR
        rm -rf INCA_libs
        source /usr/cad/cadence/cshrc
        sed -i 's/^\`define CYCLE.*$/\`define CYCLE $cycle_from/' \
            test/baseline/testbench/Final_tb.v
        ncverilog \
            test/baseline/testbench/Final_tb.v \
            CHIP_syn.v \
            lib/slow_memory.v \
            /home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v \
            +incdir+test/baseline/testbench \
            +incdir+test/brPred/testbench \
            +incdir+test/l2cache/testbench \
            +incdir+test/mulDiv/testbench \
            +incdir+include \
            +incdir+src \
            $defines +define+SDF +access+r
    " | tee gate.log
fi

