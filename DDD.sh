#!/bin/bash

#
#                        ■■■■    ■■■■■   ■■■■■   ■■■■
#                        ■   ■   ■       ■       ■   ■
#                        ■   ■   ■■■■    ■■■■    ■■■■
#                        ■   ■   ■       ■       ■
#                        ■■■■    ■■■■■   ■■■■■   ■
#             
#                        ■■■■      ■     ■■■■    ■   ■  
#                        ■   ■    ■ ■    ■   ■   ■  ■   
#                        ■   ■   ■   ■   ■■■■    ■■■   
#                        ■   ■   ■■■■■   ■  ■    ■  ■  
#                        ■■■■    ■   ■   ■   ■   ■   ■ 
#            
#            ■■■■    ■   ■   ■   ■    ■■■■   ■■■■■    ■■■    ■   ■ 
#            ■   ■   ■   ■   ■■  ■   ■       ■       ■   ■   ■■  ■ 
#            ■   ■   ■   ■   ■ ■ ■   ■  ■■   ■■■■    ■   ■   ■ ■ ■ 
#            ■   ■   ■   ■   ■  ■■   ■   ■   ■       ■   ■   ■  ■■ 
#            ■■■■     ■■■    ■   ■    ■■■    ■■■■■    ■■■    ■   ■ 
#               
#                                                               By Neprim
 
#----------------------------------------------------------------------+
#Color picker, usage: printf ${BLD}${CUR}${RED}${BBLU}"Some text"${DEF}|
#---------------------------+--------------------------------+---------+
#        Text color         |       Background color         |         |
#------------+--------------+--------------+-----------------+         |
#    Base    |Lighter\Darker|    Base      | Lighter\Darker  |         |
#------------+--------------+--------------+-----------------+         |
RED='\e[31m'; LRED='\e[91m'; BRED='\e[41m'; BLRED='\e[101m' #| Red     |
GRN='\e[32m'; LGRN='\e[92m'; BGRN='\e[42m'; BLGRN='\e[102m' #| Green   |
YLW='\e[33m'; LYLW='\e[93m'; BYLW='\e[43m'; BLYLW='\e[103m' #| Yellow  |
BLU='\e[34m'; LBLU='\e[94m'; BBLU='\e[44m'; BLBLU='\e[104m' #| Blue    |
MGN='\e[35m'; LMGN='\e[95m'; BMGN='\e[45m'; BLMGN='\e[105m' #| Magenta |
CYN='\e[36m'; LCYN='\e[96m'; BCYN='\e[46m'; BLCYN='\e[106m' #| Cyan    |
GRY='\e[37m'; DGRY='\e[90m'; BGRY='\e[47m'; BDGRY='\e[100m' #| Gray    |
#------------------------------------------------------------+---------+
# Effects                                                              |
#----------------------------------------------------------------------+
DEF='\e[0m'   # Default color and effects                              |
BLD='\e[1m'   # Bold\brighter                                          |
DIM='\e[2m'   # Dim\darker                                             |
CUR='\e[3m'   # Italic font                                            |
UND='\e[4m'   # Underline                                              |
INV='\e[7m'   # Inverted                                               |
COF='\e[?25l' # Cursor Off                                             |
CON='\e[?25h' # Cursor On                                              |
#----------------------------------------------------------------------+
# Text positioning, usage: XY 10 10 "Some text"                        |
XY   () { printf "\e[${2};${1}H${3}";   } #                            |
#----------------------------------------------------------------------+
# Line, usage: line - 10 | line -= 20 | line "word1 word2 " 20         |
line () { printf %.s"${1}" $(seq ${2}); } #                            |
#----------------------------------------------------------------------+

basic_gray_back='\033[01;48;05;250m'
light_gray_back='\033[01;48;05;254m'

basic_gray_fore='\033[01;38;05;242m'
door_fore='\033[01;38;05;173m'

pure_white_fore='\033[01;38;05;15m'

function draw_with_offset {
    XY $((${1} + $x_offset)) $((${2} + $y_offset)) ${3}
}

function generate_dungeon() {
    echo "" > test.txt

    updated=0
    player_can_move=0
    clear

    cur_room_width=${1}
    cur_room_height=${2}
    echo "$cur_room_width $cur_room_height" >> test.txt
    iters=${3}
    declare -a owner
    declare -a checked
    dungeon_map=()
    seen=()
    for ((i=0; i<${cur_room_height}; i++)); do
        for ((j=0; j< ${cur_room_width}; j++)); do
            dungeon_map[$(($i * $cur_room_width + $j))]=" "
            owner[$(($i * $cur_room_width + $j))]=-1
            checked[$(($i * $cur_room_width + $j))]=0
            seen[$(($i * $cur_room_width + $j))]=0
            #draw_with_offset $j $i "${DEF} "
        done
    done

    XY $(($window_width/2 - 10)) $(($window_height/2 - 0)) " Generating Dungeon"

    sectors[0]="2; $(($cur_room_width - 3)); 2; $(($cur_room_height - 3))"
    sc_pointer=0
    sectors_size=1

    # Помещаем границы по краям карты
    for ((i=1; i<${cur_room_height}-1; i++)); do
        dungeon_map[$(($i * $cur_room_width + 1))]="-"
        dungeon_map[$(($i * $cur_room_width + $cur_room_width - 2))]="-"
    done
    for ((j=1; j< ${cur_room_width}-1; j++)); do
        dungeon_map[$(((                 1) * $cur_room_width + $j))]="-"
        dungeon_map[$((($cur_room_height-2) * $cur_room_width + $j))]="-"
    done

    XY $(($window_width/2 - 10)) $(($window_height/2 + 1)) "    Placing rooms   "

    for ((i=0; i<$iters; i++)); do
        sc_am=$(($sectors_size - $sc_pointer))
        for ((j=0; j<$sc_am; j++)); do
            IFS='; ' read -r -a sc <<< "${sectors[$sc_pointer]}"; ((sc_pointer++))
            
            if (( ${sc[1]} - ${sc[0]} > ${sc[3]} - ${sc[2]} )); then #Если широта больше высоты
                if (( ${sc[1]} - ${sc[0]} > $rm_min_size * 2 )); then
                # Находим минимальное расстояние от границ для деления (max(3, 25%))
                    minl=$(( (${sc[1]} - ${sc[0]})*25/100 )); [ $minl -lt $rm_min_size ] && minl=$rm_min_size      
                # И выбираем черту деления случайным образом
                    del=$(( ${sc[0]} + ($minl + RANDOM % (${sc[1]} - ${sc[0]} + 1 - 2 * $minl) ) ))  
                # Создаём два новых сектора по черте                              
                    sectors[$sectors_size]="${sc[0]}; $(($del - 1)); ${sc[2]}; ${sc[3]}"; ((sectors_size++))
                    sectors[$sectors_size]="$(($del + 1)); ${sc[1]}; ${sc[2]}; ${sc[3]}"; ((sectors_size++))
                # И помещаем черту в карту (нужно будет для проложения путей)
                    for ((ii=${sc[2]}; ii<=${sc[3]}; ii++)); do
                        dungeon_map[$(($ii * $cur_room_width + $del))]="-"
                    done
                else
                    sectors[$sectors_size]="${sc[0]}; ${sc[1]}; ${sc[2]}; ${sc[3]}"; ((sectors_size++))
                fi
            else
                if (( ${sc[3]} - ${sc[2]} > $rm_min_size * 2 )); then
                    minl=$(( (${sc[3]} - ${sc[2]})*25/100 )); [ $minl -lt $rm_min_size ] && minl=$rm_min_size       
                    del=$(( ${sc[2]} + ($minl + RANDOM % (${sc[3]} - ${sc[2]} + 1 - 2 * $minl) ) ))          
                    sectors[$sectors_size]="${sc[0]}; ${sc[1]}; ${sc[2]}; $(($del - 1))"; ((sectors_size++))
                    sectors[$sectors_size]="${sc[0]}; ${sc[1]}; $(($del + 1)); ${sc[3]}"; ((sectors_size++))

                    for ((jj=${sc[0]}; jj<=${sc[1]}; jj++)); do
                        dungeon_map[$(($del * $cur_room_width + $jj))]="-"
                    done
                else
                    sectors[$sectors_size]="${sc[0]}; ${sc[1]}; ${sc[2]}; ${sc[3]}"; ((sectors_size++))
                fi
            fi
        done
    done

    declare -a dsu
    function get() {
        if (( ${1} == ${dsu[${1}]} )); then 
            echo ${1}
        else
            dsu[${1}]=$(get ${dsu[${1}]})
            echo ${dsu[${1}]} 
        fi
    }
    
    function unite() {
        local a=$(get ${1})
        local b=$(get ${2})
        dsu[$a]=$b
    }

    function same() {
        if [ $(get ${1}) -eq $(get ${2}) ]; then echo "1"; else echo "0"; fi
    }

    declare -a rooms
    rm_pointer=0

    #       1
    #       ↑
    #   8 ← 0 → 2
    #       ↓
    #       4
    
    declare -a doors 

    for ((r=$sc_pointer; r<${#sectors[@]}; r++)); do
        IFS='; ' read -r -a rm <<< "${sectors[$r]}"
        # Вначале пытаемся подставить комнату из шаблонов. Иначе генерируем коробку.
        flag=$((RANDOM % 2))

        dsu[$rm_pointer]=$rm_pointer

        if [ $flag -eq 0 ]; then
            IFS=' ' read -r -a gen_rooms <<< "$(ls ./Rooms/*.dddroom | sed -z 's/\n/ /g')"
            if [ ${#gen_rooms[@]} -gt 0 ]; then
                ch_room_name=${gen_rooms[$((RANDOM % ${#gen_rooms[@]}))]}

                declare -a ch_room
                ch_room_pointer=0
                
                IFS=""
                while read line; do
                    line=$(echo $line | tr -d '\r\n')
                    ch_room[$ch_room_pointer]=$line; ((ch_room_pointer++))
                done < $ch_room_name

                IFS=' ' read -r -a ch_room_params <<< "${ch_room[0]}"

                rm_w=${ch_room_params[0]}
                rm_h=${ch_room_params[1]}


                (( $rm_w > ${rm[1]} - ${rm[0]} + 1 || $rm_h > ${rm[3]} - ${rm[2]} + 1 )) && flag=1
                if [ $flag -eq 0 ]; then 
                    rm_x=$(( ${rm[0]} + RANDOM % (${rm[1]} - ${rm[0]} + 2 - $rm_w) ))
                    rm_y=$(( ${rm[2]} + RANDOM % (${rm[3]} - ${rm[2]} + 2 - $rm_h) ))

                    rooms[$rm_pointer]="$rm_x; $(($rm_x + $rm_w - 1)); $rm_y; $(($rm_y + $rm_h - 1))"

                    for ((i=0; i<$rm_h; i++)); do
                        rm_layer=${ch_room[$(($i + 2))]}
                        for ((j=0; j<$rm_w; j++)); do
                            dungeon_map[$(( ($i + $rm_y) * $cur_room_width + ($j + $rm_x) ))]=${rm_layer:$j:1}
                        done
                    done
                    
                    doors[$rm_pointer]=" ${ch_room[1]}"
                    echo "${doors[$rm_pointer]}" >> test.txt
                fi
            else
                flag=1
            fi
        fi

        if [ $flag -ge 1 ]; then
            # Находим минимальные размеры комнаты для сектора
            # Минимальный поставил половину сектора, иначе часто комнаты в разы меньше секторов => много пустого пространства
            rm_min_w=$(( (${rm[1]} - ${rm[0]} + 1) / 2)); [ $rm_min_w -lt $rm_min_size ] && rm_min_w=$rm_min_size
            rm_min_h=$(( (${rm[3]} - ${rm[2]} + 1) / 2)); [ $rm_min_h -lt $rm_min_size ] && rm_min_h=$rm_min_size
            # Находим размеры комнаты
            rm_w=$(( $rm_min_w + RANDOM % (${rm[1]} - ${rm[0]} + 2 - $rm_min_w) ))
            rm_h=$(( $rm_min_h + RANDOM % (${rm[3]} - ${rm[2]} + 2 - $rm_min_h) ))
            # И её положение в секторе
            rm_x=$(( ${rm[0]} + RANDOM % (${rm[1]} - ${rm[0]} + 2 - $rm_w) ))
            rm_y=$(( ${rm[2]} + RANDOM % (${rm[3]} - ${rm[2]} + 2 - $rm_h) ))
            rooms[$rm_pointer]="$rm_x; $(($rm_x + $rm_w - 1)); $rm_y; $(($rm_y + $rm_h - 1))"

        # В любой комнате должна будет быть как минимум одна дверь
            IFS='; ' read -r -a rm <<< "${rooms[$rm_pointer]}"
            drs=$((1 + RANDOM % 15))       
            doors[$rm_pointer]=""     
            if [ $drs -ge 8 ]; then doors[$rm_pointer]="${doors[$rm_pointer]} 0 $((1 + RANDOM % (${rm[3]} - ${rm[2]} - 1) )) 8;"; ((drs = $drs - 8)); fi
            if [ $drs -ge 4 ]; then doors[$rm_pointer]="${doors[$rm_pointer]} $((1 + RANDOM % (${rm[1]} - ${rm[0]} - 1) )) $((${rm[3]} - ${rm[2]})) 4;"; ((drs = $drs - 4)); fi
            if [ $drs -ge 2 ]; then doors[$rm_pointer]="${doors[$rm_pointer]} $((${rm[1]} - ${rm[0]})) $((1 + RANDOM % (${rm[3]} - ${rm[2]} - 1) )) 2;"; ((drs = $drs - 2)); fi
            if [ $drs -ge 1 ]; then doors[$rm_pointer]="${doors[$rm_pointer]} $((1 + RANDOM % (${rm[1]} - ${rm[0]} - 1) )) 0 1;"; ((drs = $drs - 1)); fi

            echo "${doors[$rm_pointer]}" >> test.txt
        # Выставляем стенки и полы
            for ((i=${rm[2]}; i<=${rm[3]}; i++)); do
                for ((j=${rm[0]}; j<=${rm[1]}; j++)); do
                    dungeon_map[$(($i * $cur_room_width + $j))]='.'
                done
            done
            for ((i=${rm[2]}; i<=${rm[3]}; i++)); do
                dungeon_map[$(($i * $cur_room_width + ${rm[0]}))]='#'
                dungeon_map[$(($i * $cur_room_width + ${rm[1]}))]='#'
            done
            for ((j=${rm[0]}; j<=${rm[1]}; j++)); do
                dungeon_map[$((${rm[2]} * $cur_room_width + $j))]='#'
                dungeon_map[$((${rm[3]} * $cur_room_width + $j))]='#'
            done
            
        fi
        ((rm_pointer++))
    done

    # Размещение лестниц и игрока
    IFS='; ' read -r -a rm <<< "${rooms[0]}"
    dungeon_map[$(( ((${rm[3]} + ${rm[2]})/2) * $cur_room_width + ((${rm[1]} + ${rm[0]})/2) ))]='<'
    player_x=$(( (${rm[1]} + ${rm[0]})/2 ))
    player_y=$(( (${rm[3]} + ${rm[2]})/2 ))
    player_new_x=$player_x
    player_new_y=$player_y
    IFS='; ' read -r -a rm <<< "${rooms[$((${#rooms[@]} - 1))]}"
    dungeon_map[$(( ((${rm[3]} + ${rm[2]})/2) * $cur_room_width + ((${rm[1]} + ${rm[0]})/2) ))]='>'



    XY $(($window_width/2 - 10)) $(($window_height/2 + 1)) "    Making doors    "

    for ((r=0; r<${#rooms[@]}; r++)); do

        IFS='; ' read -r -a rm <<< "${rooms[$r]}"

        # Прокладываем дороги от всех дверей до переходов
        echo "${doors[$r]}" >> test.txt
        IFS=';' read -r -a drs <<< "${doors[$r]}"
        for ((i=0; i<${#drs[@]}; i++)); do
            echo "${drs[$i]}" >> test.txt
            IFS=' ' read -r -a dr <<< "${drs[$i]}"
            xx=$((${rm[0]} + ${dr[0]}))
            yy=$((${rm[2]} + ${dr[1]}))
            dir=${dr[2]}
            dungeon_map[$(( $yy  * $cur_room_width + $xx  ))]="["


            if [ $dir -eq 8 ]; then 
                xxx=$(($xx - 1))
                while [[ ${dungeon_map[$(( $yy * $cur_room_width + $xxx  ))]} != "-" ]]; do
                    dungeon_map[$(( $yy * $cur_room_width + $xxx  ))]="-"
                    owner[$(( $yy * $cur_room_width + $xxx  ))]=$r
                    ((xxx--))
                done
            fi

            if [ $dir -eq 4 ]; then 
                yyy=$(($yy + 1))
                while [[ ${dungeon_map[$(( $xx + $yyy * $cur_room_width ))]} != "-" ]]; do
                    dungeon_map[$(( $xx + $yyy * $cur_room_width  ))]="-"
                    owner[$(( $xx + $yyy * $cur_room_width  ))]=$r
                    ((yyy++))
                done
            fi

            if [ $dir -eq 2 ]; then 
                xxx=$(($xx + 1))
                while [[ ${dungeon_map[$(( $yy * $cur_room_width + $xxx  ))]} != "-" ]]; do
                    dungeon_map[$(( $yy* $cur_room_width + $xxx  ))]="-"
                    owner[$(( $yy * $cur_room_width + $xxx  ))]=$r
                    ((xxx++))
                done
            fi

            if [ $dir -eq 1 ]; then 
                yyy=$(($yy - 1))
                while [[ ${dungeon_map[$(( $xx + $yyy * $cur_room_width  ))]} != "-" ]]; do
                    dungeon_map[$(( $xx + $yyy * $cur_room_width  ))]="-"
                    owner[$(( $xx + $yyy * $cur_room_width  ))]=$r
                    ((yyy--))
                done
            fi
        done
    done
    echo " " > log.txt

    non_united_rooms=${#rooms[@]}

    function make_path() {
        rr=${1}
        drr=${2}
        check_unconnected=${3}
        IFS='; ' read -r -a rm <<< "${rooms[$rr]}"
        IFS=';' read -r -a drs <<< "${doors[$rr]}"

        echo "Room $r" >> log.txt

        IFS=' ' read -r -a dr <<< "${drs[$drr]}"
        xx=$((${rm[0]} + ${dr[0]}))
        yy=$((${rm[2]} + ${dr[1]}))
        dir=${dr[2]}
        case $dir in
            '8') echo "Left door, xx = $xx, yy = $yy" >> log.txt;;
            '4') echo "Down door, xx = $xx, yy = $yy" >> log.txt;;
            '2') echo "Right door, xx = $xx, yy = $yy" >> log.txt;;
            '1') echo "Up door, xx = $xx, yy = $yy" >> log.txt;;
        esac

        declare -a q
        qc=0            # Размер очереди
        qp=0            # Текущий элемент очереди
        if [[ ${dungeon_map[$(($yy * $cur_room_width + $xx - 1))]} =~ [\-\*] && ${checked[$(($yy * $cur_room_width + $xx - 1))]} == 0 ]]; then q[$qc]="$(($xx - 1)) $yy -1"; checked[$(($yy * $cur_room_width + $xx - 1))]=1; ((qc++)); fi
        if [[ ${dungeon_map[$(($yy * $cur_room_width + $xx + 1))]} =~ [\-\*] && ${checked[$(($yy * $cur_room_width + $xx + 1))]} == 0 ]]; then q[$qc]="$(($xx + 1)) $yy -1"; checked[$(($yy * $cur_room_width + $xx + 1))]=1; ((qc++)); fi
        if [[ ${dungeon_map[$((($yy-1) * $cur_room_width + $xx))]} =~ [\-\*] && ${checked[$((($yy-1) * $cur_room_width + $xx))]} == 0 ]]; then q[$qc]="$xx $(($yy - 1)) -1"; checked[$((($yy-1) * $cur_room_width + $xx))]=1; ((qc++)); fi
        if [[ ${dungeon_map[$((($yy+1) * $cur_room_width + $xx))]} =~ [\-\*] && ${checked[$((($yy+1) * $cur_room_width + $xx))]} == 0 ]]; then q[$qc]="$xx $(($yy + 1)) -1"; checked[$((($yy+1) * $cur_room_width + $xx))]=1; ((qc++)); fi

        while (( $qp < $qc )); do
            IFS=' ' read -r -a nd <<< "${q[$qp]}"
            xx=${nd[0]}
            yy=${nd[1]}
            par=${nd[2]}
            checked[$(($yy * $cur_room_width + $xx))]=1
            flag=0
            echo "XX: $xx, YY: $yy, Par: $par" >> log.txt
            if [[ ${owner[$(($yy * $cur_room_width + $xx))]} > -1 && ${owner[$(($yy * $cur_room_width + $xx))]} != $r && ( $check_unconnected == "0" || $(same ${owner[$(($yy * $cur_room_width + $xx))]} $rr) == "0" ) ]]; then
                echo "Found ${owner[$(($yy * $cur_room_width + $xx))]}" >> log.txt
                echo "Non connected rooms: $non_united_rooms" >> log.txt
                if [[ $(same ${owner[$(($yy * $cur_room_width + $xx))]} $rr) == "0" ]]; then unite ${owner[$(($yy * $cur_room_width + $xx))]} $rr; ((non_united_rooms--)); fi
                echo "Non connected rooms: $non_united_rooms" >> log.txt
                flag=1
                owner[$(( $xx + $yy * $cur_room_width ))]=$rr
                dungeon_map[$(( $xx + $yy * $cur_room_width ))]='*'
                while [[ $par != "-1" ]]; do
                    IFS=' ' read -r -a ppp <<< "${q[$par]}"
                    xx=${ppp[0]}
                    yy=${ppp[1]}
                    par=${ppp[2]}

                    # echo "  $par" >> log.txt
                    owner[$(( $xx + $yy * $cur_room_width ))]=$rr
                    dungeon_map[$(( $xx + $yy * $cur_room_width ))]='*'
                done
            fi

            [ $flag -eq 1 ] && break

            if [[ ${dungeon_map[$(($yy * $cur_room_width + $xx - 1))]} =~ [\-\*] && ${checked[$(($yy * $cur_room_width + $xx - 1))]} == 0 ]]; then q[$qc]="$(($xx - 1)) $yy $qp"; checked[$(($yy * $cur_room_width + $xx - 1))]=1; ((qc++)); fi
            if [[ ${dungeon_map[$(($yy * $cur_room_width + $xx + 1))]} =~ [\-\*] && ${checked[$(($yy * $cur_room_width + $xx + 1))]} == 0 ]]; then q[$qc]="$(($xx + 1)) $yy $qp"; checked[$(($yy * $cur_room_width + $xx + 1))]=1; ((qc++)); fi
            if [[ ${dungeon_map[$((($yy-1) * $cur_room_width + $xx))]} =~ [\-\*] && ${checked[$((($yy-1) * $cur_room_width + $xx))]} == 0 ]]; then q[$qc]="$xx $(($yy - 1)) $qp"; checked[$((($yy-1) * $cur_room_width + $xx))]=1; ((qc++)); fi
            if [[ ${dungeon_map[$((($yy+1) * $cur_room_width + $xx))]} =~ [\-\*] && ${checked[$((($yy+1) * $cur_room_width + $xx))]} == 0 ]]; then q[$qc]="$xx $(($yy + 1)) $qp"; checked[$((($yy+1) * $cur_room_width + $xx))]=1; ((qc++)); fi

            ((qp++))
        done

        for ((j=0; j<$qc; j++)); do
            IFS=' ' read -r -a nd <<< "${q[$j]}"
            xx=${nd[0]}
            yy=${nd[1]}
            checked[$(($yy * $cur_room_width + $xx))]=0
        done
    }

    XY $(($window_width/2 - 10)) $(($window_height/2 + 1)) "    Laying roads    "
    for ((r=0; r<${#rooms[@]}; r++)); do
        XY $(($window_width/2 - 15)) $(($window_height/2 + 2)) "    $(($non_united_rooms-1)) non-united rooms left    "
        IFS=';' read -r -a drs <<< "${doors[$r]}"
        for ((i=0; i<${#drs[@]}; i++)); do
            make_path $r $i 0
        done
    done

    while ((non_united_rooms > 1)); do
        XY $(($window_width/2 - 15)) $(($window_height/2 + 2)) "    $(($non_united_rooms-1)) non-united rooms left    "
        ch_rm=$(( RANDOM % ${#rooms[@]} ))
        IFS=';' read -r -a drs <<< "${doors[$ch_rm]}"
        make_path $ch_rm $((RANDOM % ${#drs[@]})) 1
    done

    
    XY $(($window_width/2 - 10)) $(($window_height/2 + 1)) "   Updating tiles   "

    # Преобработка

    for ((i=0; i<${room_height}; i++)); do
        for ((j=0; j<${room_width}; j++)); do
            XY $(($window_width/2 - 15)) $(($window_height/2 + 2)) "          ($(($i * $room_width + $j))/$(($room_width * $room_height)))            "
            point=${dungeon_map[$(($i * $room_width + $j))]}
            if [[ $point == '*' ]]; then 
                dungeon_map[$(($i * $room_width + $j))]='.'; 
                [[ ${dungeon_map[$(($i * $room_width + $j + 1))]} =~ [\-\ \|\_\‾] ]] && dungeon_map[$(($i * $room_width + $j + 1))]='#'
                [[ ${dungeon_map[$(($i * $room_width + $j - 1))]} =~ [\-\ \|\_\‾] ]] && dungeon_map[$(($i * $room_width + $j - 1))]='#'
                [[ ${dungeon_map[$((($i+1) * $room_width + $j))]} =~ [\-\ \|\_\‾] ]] && dungeon_map[$((($i+1) * $room_width + $j))]='#'
                [[ ${dungeon_map[$((($i-1) * $room_width + $j))]} =~ [\-\ \|\_\‾] ]] && dungeon_map[$((($i-1) * $room_width + $j))]='#'

                [[ ${dungeon_map[$((($i+1) * $room_width + $j + 1))]} =~ [\-\ \|\_\‾] ]] && dungeon_map[$((($i+1) * $room_width + $j + 1))]='#'
                [[ ${dungeon_map[$((($i-1) * $room_width + $j + 1))]} =~ [\-\ \|\_\‾] ]] && dungeon_map[$((($i-1) * $room_width + $j + 1))]='#'
                [[ ${dungeon_map[$((($i+1) * $room_width + $j - 1))]} =~ [\-\ \|\_\‾] ]] && dungeon_map[$((($i+1) * $room_width + $j - 1))]='#'
                [[ ${dungeon_map[$((($i-1) * $room_width + $j - 1))]} =~ [\-\ \|\_\‾] ]] && dungeon_map[$((($i-1) * $room_width + $j - 1))]='#'
            fi
            [[ $point == '-' ]] && dungeon_map[$(($i * $room_width + $j))]=" "
            [[ $point =~ [\|\_\‾] ]] && dungeon_map[$(($i * $room_width + $j))]=" "
        done
    done

    XY $(($window_width/2 - 10)) $(($window_height/2 + 0)) "                    "
    XY $(($window_width/2 - 10)) $(($window_height/2 + 1)) "                    "
    XY $(($window_width/2 - 15)) $(($window_height/2 + 2)) "                              "

    # Отрисовка

    # for ((i=0; i<${room_height}; i++)); do
    #     for ((j=0; j<${room_width}; j++)); do
    #         point=${dungeon_map[$(($i * $room_width + $j))]}
    #         mod=${DEF}
    #         [[ $point =~ [\.\#\<\>] ]] && mod=${BDGRY}
    #         [[ $point =~ [\*] ]] && mod=${DEF}${BCYN}
    #         [[ $point =~ [\[] ]] && mod=${BDGRY}
    #         draw_with_offset $j $i "$mod$point${DEF}"
    #     done
    # done

    player_can_move=1

    updated=1

    update_player_position

    last_time=$( date +%s )
}

function save_room() {
    updated=0

    dungeon_map_in_string=""
    dungeon_seen_in_string=""

    for ((i=0; i<${room_height}; i++)); do
        for ((j=0; j< ${room_width}; j++)); do
            dungeon_map_in_string="${dungeon_map_in_string}${dungeon_map[$(($i * $cur_room_width + $j))]};"
            dungeon_seen_in_string="${dungeon_seen_in_string}${seen[$(($i * $cur_room_width + $j))]};"
        done
    done

    dungeon_floors_map[${dungeon_floor}]=$dungeon_map_in_string
    dungeon_floors_seen[${dungeon_floor}]=$dungeon_seen_in_string
    dungeon_floors_pl_coords[${dungeon_floor}]="${player_x} ${player_y} "

    updated=1
}

function draw_dungeon_floor_UI() {
    XY $((${window_width} / 4 )) 2 "Dungeon Level: ${dungeon_floor}"
}

function redraw_map() {
    clear

    draw_dungeon_floor_UI

    for ((i=0; i<${room_height}; i++)); do
        for ((j=0; j< ${room_width}; j++)); do
            if [ ${seen[$(($i * $room_width + $j))]} -eq 1 ]; then
                point=${dungeon_map[$(($i * $cur_room_width + $j))]}
                mod=${basic_gray_back}
                [[ $point =~ [\ ] ]] && mod=${DEF}
                [[ $point =~ [\.\#\<\>] ]] && mod=${mod}${basic_gray_fore}
                [[ $point =~ [\*] ]] && mod=${mod}${BCYN}
                [[ $point =~ [\[] ]] && mod=${mod}${door_fore}
                draw_with_offset $j $i "$mod$point${DEF}"
            fi
        done
    done
}

function load_room() {
    updated=0

    IFS=';' read -r -a dungeon_map <<< "${dungeon_floors_map[$dungeon_floor]}"
    IFS=';' read -r -a seen <<< "${dungeon_floors_seen[$dungeon_floor]}"
    IFS=' ' read -r -a player_coords <<< "${dungeon_floors_pl_coords[$dungeon_floor]}"
    player_x=${player_coords[0]}
    player_y=${player_coords[1]}
    player_new_x=$player_x
    player_new_y=$player_y

    redraw_map

    update_player_position

    updated=1
}

echo "" > test2.txt
function player_can_move_here() {
    if [[ ${dungeon_map[$(($player_new_y * $cur_room_width + $player_new_x))]} =~ [\.\*\<\>] ]]; then
        echo "1"
    else
        player_new_x=$player_x
        player_new_y=$player_y
        echo "0"
    fi
}

function update_point() {
    i=${1}
    j=${2}
    
    point=${dungeon_map[$(($j * $room_width + $i))]}
    mod=${basic_gray_back}
    [[ $point =~ [\ ] ]] && mod=${DEF}
    if (( ($player_new_x - $i) * ($player_new_x - $i) + ($player_new_y - $j) * ($player_new_y - $j) < $player_vision_radius * $player_vision_radius )); then 
        mod="${light_gray_back}"
    fi
    [[ $point =~ [\.\#\<\>] ]] && mod=${mod}${basic_gray_fore}
    [[ $point =~ [\*] ]] && mod=${mod}${BCYN}
    [[ $point =~ [\[] ]] && mod=${mod}${door_fore}
    if [[ $player_x == $i && $player_y == $j ]]; then mod=${light_gray_back}${CYN}; point="@"; fi
    [ ${seen[$(($j * $room_width + $i))]} -eq 1 ] && draw_with_offset $i $j "${mod}${point}${DEF}"
    [ ${seen[$(($j * $room_width + $i))]} -eq 0 ] && draw_with_offset $i $j "${DEF}\x20"
}

function update_player_position() {

    if [[ ${dungeon_map[$(($player_new_y * $cur_room_width + $player_new_x))]} =~ [\.\*\<\>\[] ]]; then
        left=$(($player_new_x - $player_vision_radius - 2)); [ $left -lt 0 ] && left=0
        right=$(($player_new_x + $player_vision_radius + 2)); [ $right -gt $(($room_width-1)) ] && right=$(($room_width-1))
        top=$(($player_new_y - $player_vision_radius - 2)); [ $top -lt 0 ] && top=0
        bottom=$(($player_new_y + $player_vision_radius + 2)); [ $bottom -gt $(($room_height-1)) ] && bottom=$(($room_height-1))

        for ((i=$left; i<=$right; i++)) do
            for ((j=$top; j<=$bottom; j++)) do
                point=${dungeon_map[$(($j * $cur_room_width + $i))]}
                mod=${basic_gray_back}
                [[ $point =~ [\ ] ]] && mod=${DEF}
                if (( ($player_new_x - $i) * ($player_new_x - $i) + ($player_new_y - $j) * ($player_new_y - $j) < $player_vision_radius * $player_vision_radius )); then 
                    #mod="$mod${BLYLW}${DGRY}"
                    mod="${light_gray_back}"
                    seen[$(($j * $cur_room_width + $i))]=1
                fi
                [[ $point =~ [\.\#\<\>] ]] && mod=${mod}${basic_gray_fore}
                [[ $point =~ [\*] ]] && mod=${mod}${BCYN}
                [[ $point =~ [\[] ]] && mod=${mod}${door_fore}
                [ ${seen[$(($j * $cur_room_width + $i))]} -eq 1 ] && draw_with_offset $i $j "${mod}${point}${DEF}"
            done
        done

        player_x=$player_new_x
        player_y=$player_new_y
        draw_with_offset $player_x $player_y "${light_gray_back}${CYN}@${DEF}"
    else
        [[ ${dungeon_map[$(($player_new_y * $cur_room_width + $player_new_x))]} =~ [\#] ]] && push_log_message "You bummed in the wall."
        player_new_x=$player_x
        player_new_y=$player_y
    fi
    
}

function move_to_floor() {
    if [ -z ${dungeon_floors_map[$dungeon_floor]} ]; then
        generate_dungeon $room_width $room_height 1
        draw_dungeon_floor_UI
    else
        load_room
    fi
}

function descend_downstairs() {
    if [[ ${dungeon_map[$(($player_y * $cur_room_width + $player_x))]} == ">" ]]; then
        save_room
        ((dungeon_floor++))
        move_to_floor
        push_log_message "You descended to the dungeon floor ${dungeon_floor}"
    else 
        push_log_message "There are no stairs to descend."
    fi
}

function ascend_upstairs() {
    if [[ ${dungeon_map[$(($player_y * $cur_room_width + $player_x))]} == "<" ]]; then
        if [[ $dungeon_floor > 0 ]]; then
            save_room
            ((dungeon_floor--))
            move_to_floor
            push_log_message "You ascended to the dungeon floor ${dungeon_floor}"
        else
            push_log_message "You can't escape from the Deep Dark Dungeon so easily!"
        fi
    else 
        push_log_message "There are no stairs to ascend."
    fi
}

function reveal_map() {
    draw_dungeon_floor_UI

    for ((i=0; i<${room_height}; i++)); do
        for ((j=0; j< ${room_width}; j++)); do
            seen[$(($i * $room_width + $j))]=1
            point=${dungeon_map[$(($i * $cur_room_width + $j))]}
            mod=${basic_gray_back}
            [[ $point =~ [\ ] ]] && mod=${DEF}
            [[ $point =~ [\.\#\<\>] ]] && mod=${mod}${basic_gray_fore}
            [[ $point =~ [\*] ]] && mod=${mod}${BCYN}
            [[ $point =~ [\[] ]] && mod=${mod}${door_fore}
            draw_with_offset $j $i "$mod$point${DEF}"
        done
    done

    update_player_position
}

function start_new_game() {
    window_width=$( tput cols  )
    window_height=$( tput lines )

    if (( $window_width < $min_window_width || $window_height < $min_window_height )); then
        err_mess1="Cannot start a game - console window is too small."
        err_mess2="Min width: ${min_window_width} symbols, min height: ${min_window_height} symbols"
        XY $(($window_width / 2 - ${#err_mess1} / 2)) $(($window_height / 2 + 12 + 3)) "$err_mess1"
        XY $(($window_width / 2 - ${#err_mess2} / 2)) $(($window_height / 2 + 12 + 4)) "$err_mess2"

        return
    fi

    x_offset=$((($window_width - $min_window_width)/2 + 2))
    y_offset=4 # $(($window_height - $min_window_height + 2))
    log_message_y=$(($y_offset + $room_height + 1))
    just_big_enough_string=""
    for ((i=0; i<${window_width}; i++)); do
        just_big_enough_string="$just_big_enough_string "
    done

    cur_screen="the_dungeon"
    updated=0
    move_to_floor

    push_log_message "So, you decided to enter the Deep Dark Dungeon..."

    updated=1
}

declare -a game_name
     game_name[0]="            ■■■■    ■■■■■   ■■■■■   ■■■■             "
     game_name[1]="            ■   ■   ■       ■       ■   ■            "
     game_name[2]="            ■   ■   ■■■■    ■■■■    ■■■■             "
     game_name[3]="            ■   ■   ■       ■       ■                "
     game_name[4]="            ■■■■    ■■■■■   ■■■■■   ■                "
     game_name[5]="                                                     "
     game_name[6]="            ■■■■      ■     ■■■■    ■   ■            "
     game_name[7]="            ■   ■    ■ ■    ■   ■   ■  ■             "
     game_name[8]="            ■   ■   ■   ■   ■■■■    ■■■              "
     game_name[9]="            ■   ■   ■■■■■   ■  ■    ■  ■             "
    game_name[10]="            ■■■■    ■   ■   ■   ■   ■   ■            "
    game_name[11]="                                                     "
    game_name[12]="■■■■    ■   ■   ■   ■    ■■■■   ■■■■■    ■■■    ■   ■"
    game_name[13]="■   ■   ■   ■   ■■  ■   ■       ■       ■   ■   ■■  ■"
    game_name[14]="■   ■   ■   ■   ■ ■ ■   ■  ■■   ■■■■    ■   ■   ■ ■ ■"
    game_name[15]="■   ■   ■   ■   ■  ■■   ■   ■   ■       ■   ■   ■  ■■"
    game_name[16]="■■■■     ■■■    ■   ■    ■■■    ■■■■■    ■■■    ■   ■"
    game_name[17]="                                                     "
    game_name[18]="                                            By Neprim"
function draw_main_menu() {
    window_width=$( tput cols  )
    window_height=$( tput lines )
    name_height=${#game_name[@]}
    name_width=${#game_name[0]}
    press_start="Press Z to start"
    
    for ((i=0; i<${#game_name[@]}; i++)); do
        XY $(($window_width / 2 - $name_width / 2)) $(($window_height / 2 - ${#game_name[@]} / 2 - 3 + $i)) "\033[01;38;05;54m${game_name[$i]}${DEF}"
    done
    XY $(($window_width / 2 - ${#press_start} / 2)) $(($window_height / 2 + ${#game_name[@]} / 2 + 3)) "$press_start"

    updated=1
}

function update_time() {
    if (( $( date +%s ) > $last_time )); then
        (( time_played=$time_played + ($( date +%s ) - $last_time) ))
        last_time=$( date +%s )
    fi
    XY $((${window_width} / 4 * 3)) 2 "Time played: $( date -d@${time_played} -u +%H:%M:%S )"
}

function push_log_message() {
    local ccc=""
    [ $log_message_counter -gt 1 ] && ccc=" (x${log_message_counter})"
    XY 0 $log_message_y $just_big_enough_string
    XY $(($window_width/2 - ${#log_message}/2)) $log_message_y "${DGRY}$log_message$ccc${DEF}"
    XY 0 $(($log_message_y + 2)) $just_big_enough_string
    if [[ $log_message == ${1} ]]; then 
        ((log_message_counter++)) 
    else 
        log_message_counter=1
        ccc=""
    fi
    [ $log_message_counter -gt 1 ] && ccc=" (x${log_message_counter})"
    log_message=${1}
    XY $(($window_width/2 - ${#log_message}/2)) $(($log_message_y + 2)) "${pure_white_fore}$log_message$ccc${DEF}"
}

function update_target_position() {
    [ $target_new_x -ge $room_width ] && target_new_x=$(($room_width - 1))
    [ $target_new_y -ge $room_height ] && target_new_y=$(($room_height - 1))
    [ $target_new_x -lt 0 ] && target_new_x=0
    [ $target_new_y -lt 0 ] && target_new_y=0

    update_point $target_x $target_y

    target_x=$target_new_x
    target_y=$target_new_y

    mod=${BRED}
    point=${dungeon_map[$(($target_y * $cur_room_width + $target_x))]}
    [ ${seen[$(($target_y * $cur_room_width + $target_x))]} -eq 0 ] && point=" "
    draw_with_offset $target_x $target_y "${mod}${point}${DEF}"
}

function look_at_something() {
    player_can_move=0
    targeting=1
    target_x=$player_x
    target_y=$player_y
    target_new_x=$target_x
    target_new_y=$target_y
    target_execution="look_here"
    update_target_position

    push_log_message "You decided to look at..."
}

function look_here() {
    update_point $target_x $target_y
    i=$target_x
    j=$target_y
    
    mess="You looked at... something."
    point=${dungeon_map[$(($j * $room_width + $i))]}
    if (( ($player_new_x - $i) * ($player_new_x - $i) + ($player_new_y - $j) * ($player_new_y - $j) < $player_vision_radius * $player_vision_radius )); then 
        mess="You looked at"
    else
        mess="You remembered that here is"
    fi
    [[ $point =~ [\ ] ]] && mess="You looked into the void. Void looked into you."
    [[ $point =~ [\.] ]] && mess="${mess} dungeon floor. Nothing special."
    [[ $point =~ [\#] ]] && mess="${mess} dungeon wall. Nothing special."
    [[ $point =~ [\*] ]] && mess="${mess} something that shouldn't be in release version."
    [[ $point =~ [\[] ]] && mess="${mess} opened door."
    [[ $point =~ [\<] ]] && mess="${mess} upstairs."
    [[ $point =~ [\>] ]] && mess="${mess} downstairs."
    [[ $player_x == $i && $player_y == $j ]] && mess="You looked at yourself. It's you, %%player_name%%!"

    [ ${seen[$(($j * $room_width + $i))]} -eq 0 ] && mess="You don't know, what is here."

    push_log_message $mess
}

function execute_target() {
    ( $target_execution )
    player_can_move=1
    targeting=0
    target_execution=""
}


# Выход из программы, возврат курсора
#-----------------------------------------------------------------------
function bye () {
	stty echo
	printf "${CON}${DEF}"
    clear
	exit
}

 printf "${COF}"
 stty -echo
 clear
 trap bye 1 2 3 8 9 15
 trap - SIGALRM
#-----------------------------------------------------------------------

# Глобальные переменные
declare -a dungeon_map
declare -a seen
declare -a dungeon_floors_map
declare -a dungeon_floors_seen
declare -a dungeon_floors_pl_coords
dungeon_floor=0

room_width=120
room_height=30

min_window_width=$(($room_width + 1 * 2))
# Отступы в как минимум 1 клетку с каждой стороны
min_window_height=$(($room_height + 4 + 5))
# 3 клетки UI сверху и отступ + сама комната + клетка на отступ с тремя линиями под отрисовку сообщений + отступ

window_width=$( tput cols  )
window_height=$( tput lines )

y_offset=4
x_offset=2
log_message_y=0
just_big_enough_string="                                      "

player_x=0
player_y=0
player_new_x=0
player_new_y=0

player_can_move=0
targeting=0
target_x=0
target_y=0
target_new_x=0
target_new_y=0
target_execution=""


rm_min_size=5

player_vision_radius=4

# Начало игры

cur_screen="main_menu"
updated=0
time_played=0
last_time=$( date +%s )

# generate_dungeon $room_width $room_height 4

log_message=""
log_message_counter=1

XY $window_width $window_height " "

while true; do
    if [[ $cur_screen == "main_menu" ]]; then
        if [ $updated -eq 0 ]; then
            draw_main_menu
        else
            read -t0.1 -n1 input; 
            case $input in
                "z") start_new_game;;
                "я") start_new_game;;
            esac
        fi
    elif [[ $cur_screen == "the_dungeon" ]]; then
        if [ $updated -eq 0 ]; then
            smth
        else
            update_time
            if [ $player_can_move -eq 1 ]; then
                read -t0.1 -n1 input; 
                case $input in
                    "w") ((player_new_y--)); update_player_position;;
                    "ц") ((player_new_y--)); update_player_position;;
                    "a") ((player_new_x--)); update_player_position;;
                    "ф") ((player_new_x--)); update_player_position;;
                    "d") ((player_new_x++)); update_player_position;;
                    "в") ((player_new_x++)); update_player_position;;
                    "s") ((player_new_y++)); update_player_position;;
                    "ы") ((player_new_y++)); update_player_position;;
                    "r") reveal_map;;
                    "к") reveal_map;;
                    ">") descend_downstairs;;
                    "Ю") descend_downstairs;;
                    "<") ascend_upstairs;;
                    "Б") ascend_upstairs;;
                    "l") look_at_something;;
                    "д") look_at_something;;
                esac
            elif [ $targeting -eq 1 ]; then
                read -t0.1 -n1 input; 
                case $input in
                    "w") ((target_new_y--)); update_target_position;;
                    "ц") ((target_new_y--)); update_target_position;;
                    "a") ((target_new_x--)); update_target_position;;
                    "ф") ((target_new_x--)); update_target_position;;
                    "d") ((target_new_x++)); update_target_position;;
                    "в") ((target_new_x++)); update_target_position;;
                    "s") ((target_new_y++)); update_target_position;;
                    "ы") ((target_new_y++)); update_target_position;;
                    "z") execute_target;;
                    "я") execute_target;;
                esac
            fi
        fi
    fi
done

bye