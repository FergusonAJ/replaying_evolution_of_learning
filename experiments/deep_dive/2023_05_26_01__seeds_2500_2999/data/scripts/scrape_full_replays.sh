#!/bin/bash

NUM_REPS=50

#REPLAY_SEEDS="108 183 206"
#declare -a DEPTH_MAP
#DEPTH_MAP[108]="2538 2488 2438 2388 2338"
#DEPTH_MAP[183]="713 663 613 563 513"
#DEPTH_MAP[206]="1810 1760 1710 1660 1610"

#REPLAY_SEEDS="108 183"
#declare -a DEPTH_MAP
#DEPTH_MAP[108]="2288 2238 2188 2138 2088 2038"
#DEPTH_MAP[183]="463 413 363 313 263 213"

#REPLAY_SEEDS="108"
#declare -a DEPTH_MAP
#DEPTH_MAP[108]="1988 1938 1888 1838 1788 1738"

#REPLAY_SEEDS="108"
#declare -a DEPTH_MAP
#DEPTH_MAP[108]="1688 1638 1588 1538 1488 1438"

#REPLAY_SEEDS="108"
#declare -a DEPTH_MAP
#DEPTH_MAP[108]="1388 1338 1288 1238 1188 1138"

#REPLAY_SEEDS="108"
#declare -a DEPTH_MAP
#DEPTH_MAP[108]="1088 1038 988 938 888 838"

#REPLAY_SEEDS="108"
#declare -a DEPTH_MAP
#DEPTH_MAP[108]="788 738 688 638 588 538 488 438 388 338 288 238 188 138 88 38"

# Targeted replays
REPLAY_SEEDS="108 183 206"
declare -a DEPTH_MAP
DEPTH_MAP[108]="2489 2490 2491 2492 2493 2494 2495 2496 2497 2498 2499 2500 2501 2502 2503 2504 2505 2506 2507 2508 2509 2510 2511 2512 2513 2514 2515 2516 2517 2518 2519 2520 2521 2522 2523 2524 2525 2526 2527 2528 2529 2530 2531 2532 2533 2534 2535 2536 2537"
DEPTH_MAP[183]="614 615 616 617 618 619 620 621 622 623 624 625 626 627 628 629 630 631 632 633 634 635 636 637 638 639 640 641 642 643 644 645 646 647 648 649 650 651 652 653 654 655 656 657 658 659 660 661 662"
DEPTH_MAP[206]="1661 1662 1663 1664 1665 1666 1667 1668 1669 1670 1671 1672 1673 1674 1675 1676 1677 1678 1679 1680 1681 1682 1683 1684 1685 1686 1687 1688 1689 1690 1691 1692 1693 1694 1695 1696 1697 1698 1699 1700 1701 1702 1703 1704 1705 1706 1707 1708 1709"


    
# Grab the experiment name
EXP_NAME=$(pwd | grep -oP "/\K[^/]+(?=/data|/data/scripts)")

# Grab global config variables
REPO_ROOT_DIR=$(pwd | grep -oP ".+/(?=experiments/)")
source ${REPO_ROOT_DIR}/config_global.sh

# Calculate directories to pass to R script
SCRATCH_REP_DIR=${SCRATCH_ROOT_DIR}/${EXP_NAME}/reps
OUTPUT_DIR=$(pwd | grep -oP ".+/${EXP_NAME}/data")
SCRIPT_DIR=${OUTPUT_DIR}/scripts

for REPLAY_SEED in ${REPLAY_SEEDS}
do
    echo "Starting seed: ${REPLAY_SEED}"
    for REPLAY_DEPTH in ${DEPTH_MAP[REPLAY_SEED]}
    do
        echo "  Depth: ${REPLAY_DEPTH}"
        REPLAY_SCRATCH_REP_DIR=${SCRATCH_REP_DIR}/${REPLAY_SEED}/full_replays/${REPLAY_DEPTH}
        REPLAY_OUTPUT_DIR=${OUTPUT_DIR}/reps/${REPLAY_SEED}/full_replays/${REPLAY_DEPTH}
        mkdir -p ${REPLAY_OUTPUT_DIR}
        echo ""
        echo "Pulling data from: ${REPLAY_SCRATCH_REP_DIR}"
        echo "Saving data to: ${REPLAY_OUTPUT_DIR}"
        echo ""
        Rscript ${SCRIPT_DIR}/combine_final_dominant_data.R ${REPLAY_SCRATCH_REP_DIR} ${REPLAY_OUTPUT_DIR} ${NUM_REPS}
    done
    echo "----------------"
done
