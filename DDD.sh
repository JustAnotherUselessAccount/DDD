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
 

# Цвета
#-----------------------------------------------------------------------

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

    player_blue='\033[01;38;05;21m'

    basic_gray_back='\033[01;48;05;250m'
    light_gray_back='\033[01;48;05;254m'

    basic_gray_fore='\033[01;38;05;242m'
    door_fore='\033[01;38;05;173m'

    basic_brown_fore="\033[01;38;05;166m"

    pure_white_fore='\033[01;38;05;15m'

    brown_item_fore='\033[01;38;05;124m'

    function draw_with_offset {
        XY $((${1} + $x_offset)) $((${2} + $y_offset)) ${3}
    }

    function get_random_range() {
        echo "$((${1} + RANDOM % (${2} - ${1} + 1) ))"
    }
#-----------------------------------------------------------------------



# Начало игры, отрисовка главного меню
#-----------------------------------------------------------------------
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
        local i
        for ((i=0; i<${window_width}; i++)); do
            just_big_enough_string="$just_big_enough_string "
        done

        cur_screen="the_dungeon"
        updated=0

        # open_equipment_menu
        # open_inventory_menu
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
        
        local i
        for ((i=0; i<${#game_name[@]}; i++)); do
            XY $(($window_width / 2 - $name_width / 2)) $(($window_height / 2 - ${#game_name[@]} / 2 - 3 + $i)) "\033[01;38;05;54m${game_name[$i]}${DEF}"
        done
        XY $(($window_width / 2 - ${#press_start} / 2)) $(($window_height / 2 + ${#game_name[@]} / 2 + 3)) "$press_start"

        updated=1
    }
#-----------------------------------------------------------------------



# Генерация, загрузка, сохранение и т.д.
#-----------------------------------------------------------------------
    function generate_dungeon() {
        # echo "" > test.txt

        updated=0
        player_can_move=0
        clear

        cur_room_width=${1}
        cur_room_height=${2}
        # echo "$cur_room_width $cur_room_height" >> test.txt
        iters=${3}
        declare -a owner
        declare -a checked
        dungeon_map=()
        seen=()
        dungeon_items=()
        dungeon_entities=()
        dungeon_entities_list=()
        local i
        local j
        for ((i=0; i<${cur_room_height}; i++)); do
            for ((j=0; j< ${cur_room_width}; j++)); do
                dungeon_map[$(($i * $cur_room_width + $j))]=" "
                owner[$(($i * $cur_room_width + $j))]=-1
                checked[$(($i * $cur_room_width + $j))]=0
                seen[$(($i * $cur_room_width + $j))]=0
                dungeon_entities=[$(($i * $cur_room_width + $j))]=""
                dungeon_items[$(($i * $cur_room_width + $j))]=""
            done
        done

        XY $(($window_width/2 - 10)) $(($window_height/2 - 0)) " Generating Dungeon"

        sectors[0]="2; $(($cur_room_width - 3)); 2; $(($cur_room_height - 3))"
        sc_pointer=0
        sectors_size=1
        local i
        local j

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
                        local ii
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

                        local jj
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
            local flag=$((RANDOM % 2))

            dsu[$rm_pointer]=$rm_pointer

            if [ $flag -eq 0 ]; then
                IFS=' ' read -r -a gen_rooms <<< "$(ls ./Rooms/*.dddroom | sed -z 's/\n/ /g')"
                if [ ${#gen_rooms[@]} -gt 0 ]; then
                    ch_room_name=${gen_rooms[$((RANDOM % ${#gen_rooms[@]}))]}

                    # echo "Room choice #${rm_pointer}: ${ch_room_name}" >> log.txt

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

                        local i
                        local j
                        for ((i=0; i<$rm_h; i++)); do
                            rm_layer=${ch_room[$(($i + 2))]}
                            for ((j=0; j<$rm_w; j++)); do
                                dungeon_map[$(( ($i + $rm_y) * $cur_room_width + ($j + $rm_x) ))]=${rm_layer:$j:1}
                            done
                        done
                        
                        doors[$rm_pointer]=" ${ch_room[1]}"
                        # echo "${doors[$rm_pointer]}" >> test.txt
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

                # echo "${doors[$rm_pointer]}" >> test.txt
            # Выставляем стенки и полы
                local i
                local j
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

            # В первой комнате не должно ничего генерится
            if [[ $r != $sc_pointer ]]; then
                # Пытаемся где-нибудь в комнате сгенерировать предмет, а если повезёт, то и несколько
                flag=$((RANDOM % 3))
                while [ $flag -eq 0 ]; do
                    local xxx=$(($rm_x + RANDOM % ($rm_w + 1) ))
                    local yyy=$(($rm_y + RANDOM % ($rm_h + 1) ))
                    while [[ ${dungeon_map[$(( $yyy * $room_width + $xxx))]} != "." ]]; do
                        xxx=$(($rm_x + RANDOM % ($rm_w + 1) ))
                        yyy=$(($rm_y + RANDOM % ($rm_h + 1) ))
                    done

                    generate_item_from_loot_table $cur_dunger_level
                    dungeon_items[$(($yyy * $room_width + $xxx))]="${new_item_generated},"
                    flag=$((RANDOM % 3))
                done

                # Пытаемся где-нибудь в комнате сгенерировать врага, а если не повезёт, то и несколько
                flag=$((RANDOM % 2))
                while [ $flag -eq 0 ]; do
                    local xxx=$(($rm_x + RANDOM % ($rm_w + 1) ))
                    local yyy=$(($rm_y + RANDOM % ($rm_h + 1) ))
                    while [[ ${dungeon_map[$(( $yyy * $room_width + $xxx))]} != "." && ${dungeon_entities[$(( $yyy * $room_width + $xxx))]} == "" ]]; do
                        xxx=$(($rm_x + RANDOM % ($rm_w + 1) ))
                        yyy=$(($rm_y + RANDOM % ($rm_h + 1) ))
                    done

                    generate_entity_from_danger_table $cur_dunger_level
                    local entity=$((entities_counter - 1))
                    dungeon_entities[$(($yyy * $room_width + $xxx))]=$entity
                    entities_list[${entity}, xx]=$xxx
                    entities_list[${entity}, yy]=$yyy
                    # echo "entity_id: $entity, xx: ${entities_list[${entity}, xx]}, yy: ${entities_list[${entity}, xx]}" >> log_test.txt
                    flag=$((RANDOM % 2))
                done
            fi

            ((rm_pointer++))
        done

        # Размещение лестниц и игрока
        IFS='; ' read -r -a rm <<< "${rooms[0]}"
        dungeon_map[$(( ((${rm[3]} + ${rm[2]})/2) * $cur_room_width + ((${rm[1]} + ${rm[0]})/2) ))]='<'
        player_x=$(( (${rm[1]} + ${rm[0]})/2 ))
        player_y=$(( (${rm[3]} + ${rm[2]})/2 ))
        start_player_x=$player_x
        start_player_y=$player_y
        player_new_x=$player_x
        player_new_y=$player_y
        IFS='; ' read -r -a rm <<< "${rooms[$((${#rooms[@]} - 1))]}"
        dungeon_map[$(( ((${rm[3]} + ${rm[2]})/2) * $cur_room_width + ((${rm[1]} + ${rm[0]})/2) ))]='>'



        XY $(($window_width/2 - 10)) $(($window_height/2 + 1)) "    Making doors    "

        local non_united_doors=0
        for ((r=0; r<${#rooms[@]}; r++)); do

            IFS='; ' read -r -a rm <<< "${rooms[$r]}"

            # Прокладываем дороги от всех дверей до переходов
            # echo "Doors of room #${r}: ${doors[$r]}" >> test.txt
            IFS=';' read -r -a drs <<< "${doors[$r]}"
            local i
            for ((i=0; i<${#drs[@]}; i++)); do
                ((non_united_doors++))
                # echo "Door ${i}: ${drs[$i]}" >> test.txt
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
        # echo " " > log.txt

        non_united_rooms=${#rooms[@]}

        function make_path() {
            rr=${1}
            drr=${2}
            check_unconnected=${3}
            IFS='; ' read -r -a rm <<< "${rooms[$rr]}"
            IFS=';' read -r -a drs <<< "${doors[$rr]}"

            # echo "Room $r" >> log.txt

            IFS=' ' read -r -a dr <<< "${drs[$drr]}"
            xx=$((${rm[0]} + ${dr[0]}))
            yy=$((${rm[2]} + ${dr[1]}))
            dir=${dr[2]}
            # case $dir in
            #     '8') echo "Left door, xx = $xx, yy = $yy" >> log.txt;;
            #     '4') echo "Down door, xx = $xx, yy = $yy" >> log.txt;;
            #     '2') echo "Right door, xx = $xx, yy = $yy" >> log.txt;;
            #     '1') echo "Up door, xx = $xx, yy = $yy" >> log.txt;;
            # esac

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
                # echo "XX: $xx, YY: $yy, Par: $par" >> log.txt
                if [[ ${owner[$(($yy * $cur_room_width + $xx))]} > -1 && ${owner[$(($yy * $cur_room_width + $xx))]} != $r && ( $check_unconnected == "0" || $(same ${owner[$(($yy * $cur_room_width + $xx))]} $rr) == "0" ) ]]; then
                    # echo "Found ${owner[$(($yy * $cur_room_width + $xx))]}" >> log.txt
                    # echo "Non connected rooms: $non_united_rooms" >> log.txt
                    if [[ $(same ${owner[$(($yy * $cur_room_width + $xx))]} $rr) == "0" ]]; then unite ${owner[$(($yy * $cur_room_width + $xx))]} $rr; ((non_united_rooms--)); fi
                    # echo "Non connected rooms: $non_united_rooms" >> log.txt
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
            
            local j
            for ((j=0; j<$qc; j++)); do
                IFS=' ' read -r -a nd <<< "${q[$j]}"
                xx=${nd[0]}
                yy=${nd[1]}
                checked[$(($yy * $cur_room_width + $xx))]=0
            done
        }

        XY $(($window_width/2 - 10)) $(($window_height/2 + 1)) "    Laying roads    "
        XY $(($window_width/2 - 15)) $(($window_height/2 + 3)) "    $(($non_united_doors)) non-united doors left    "
        for ((r=0; r<${#rooms[@]}; r++)); do
            XY $(($window_width/2 - 15)) $(($window_height/2 + 2)) "    $(($non_united_rooms-1)) non-united rooms left    "
            IFS=';' read -r -a drs <<< "${doors[$r]}"
            local i
            for ((i=0; i<${#drs[@]}; i++)); do
                make_path $r $i 0
                ((non_united_doors--))
                XY $(($window_width/2 - 15)) $(($window_height/2 + 3)) "    $(($non_united_doors)) non-united doors left    "
            done
        done

        while ((non_united_rooms > 1)); do
            XY $(($window_width/2 - 15)) $(($window_height/2 + 2)) "    $(($non_united_rooms-1)) non-united rooms left    "
            ch_rm=$(( RANDOM % ${#rooms[@]} ))
            IFS=';' read -r -a drs <<< "${doors[$ch_rm]}"
            make_path $ch_rm $((RANDOM % ${#drs[@]})) 1
        done

        XY $(($window_width/2 - 15)) $(($window_height/2 + 3)) "                              "
        XY $(($window_width/2 - 10)) $(($window_height/2 + 1)) "   Updating tiles   "

        # Преобработка

        local i
        local j
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

        player_can_move=1

        updated=1

        update_player_position

        last_time=$( date +%s )
    }

    function save_room() {
        updated=0

        dungeon_map_in_string=""
        dungeon_seen_in_string=""
        dungeon_entities_in_string=""
        dungeon_entities_list_in_string="${dungeon_entities_list[@]}"
        dungeon_items_in_string=""

        local i
        local j
        for ((i=0; i<${room_height}; i++)); do
            for ((j=0; j< ${room_width}; j++)); do
                dungeon_map_in_string="${dungeon_map_in_string}${dungeon_map[$(($i * $cur_room_width + $j))]};"
                dungeon_seen_in_string="${dungeon_seen_in_string}${seen[$(($i * $cur_room_width + $j))]};"
                dungeon_entities_in_string="${dungeon_entities_in_string}${dungeon_entities[$(($i * $cur_room_width + $j))]};"
                dungeon_items_in_string="${dungeon_items_in_string}${dungeon_items[$(($i * $cur_room_width + $j))]};"
            done
        done

        dungeon_floors_map[${dungeon_floor}]=$dungeon_map_in_string
        dungeon_floors_seen[${dungeon_floor}]=$dungeon_seen_in_string
        dungeon_floors_entities[${dungeon_floor}]=$dungeon_entities_in_string
        dungeon_floors_entities_list[${dungeon_floor}]=$dungeon_entities_list_in_string
        dungeon_floors_items[${dungeon_floor}]=$dungeon_items_in_string
        dungeon_floors_pl_coords[${dungeon_floor}]="${player_x} ${player_y} "

        updated=1
    }

    function load_room() {
        updated=0

        IFS=';' read -r -a dungeon_map <<< "${dungeon_floors_map[$dungeon_floor]}"
        IFS=';' read -r -a seen <<< "${dungeon_floors_seen[$dungeon_floor]}"
        IFS=';' read -r -a dungeon_entities <<< "${dungeon_floors_entities[$dungeon_floor]}"
        IFS=' ' read -r -a dungeon_entities_list <<< "${dungeon_floors_entities_list[$dungeon_floor]}"
        IFS=';' read -r -a dungeon_items <<< "${dungeon_floors_items[$dungeon_floor]}"
        IFS=' ' read -r -a player_coords <<< "${dungeon_floors_pl_coords[$dungeon_floor]}"
        player_x=${player_coords[0]}
        player_y=${player_coords[1]}
        player_new_x=$player_x
        player_new_y=$player_y

        redraw_map

        updated=1
    }

    function move_to_floor() {
        if [ -z ${dungeon_floors_map[$dungeon_floor]} ]; then
            generate_dungeon $room_width $room_height 4
            draw_dungeon_floor_GUI
        else
            load_room
        fi

        cur_dunger_level=$((${dungeon_floor} / 3 + 1))
    }
#-----------------------------------------------------------------------



# Отрисовка GUIшки и лога
#-----------------------------------------------------------------------
    function draw_dungeon_floor_GUI() {
        XY $(($x_offset )) 2 "|DL: $(($dungeon_floor + 1))|"
        update_player_hp_GUI
        update_player_stats_GUI
        update_time
    }

    function update_time() {
        if (( $( date +%s ) > $last_time )); then
            (( time_played=$time_played + ($( date +%s ) - $last_time) ))
            last_time=$( date +%s )
        fi
        local time_played_mes="Time played: $( date -d@${time_played} -u +%H:%M:%S )"
        XY $((${window_width} - 2 - ${#time_played_mes} - $x_offset)) 2 "$time_played_mes"
    }

    function update_player_hp_GUI() {
        local xx=$(( ${window_width} / 2 - 12 ))
        local hp_mes="${player_stats["hp"]}/${player_stats["max_hp"]}"
        local flag=0
        while ((${#hp_mes} < 11)); do if [ $flag -eq 0 ]; then hp_mes=" ${hp_mes}"; flag=1; else hp_mes="${hp_mes} "; flag=0; fi; done

        local slice_index=$(( (${player_stats["hp"]} * 11) / ${player_stats["max_hp"]} ))
        local i
        for ((i=0; i<$slice_index; i++)); do
            XY $(($xx + $i)) 2 "${BRED}${hp_mes:$i:1}${DEF}"
        done
        for ((i=$slice_index; i<11; i++)); do
            XY $(($xx + $i)) 2 "${BDGRY}${hp_mes:$i:1}${DEF}"
        done
    }

    function update_player_stats_GUI() {
        DV_title="|DV: ${player_stats["DV"]}|"
        PV_title="|PV: ${player_stats["PV"]}|"
        XY $(( $x_offset + 8 )) 2 "$DV_title"
        XY $(( $x_offset + 8 + ${#DV_title} + 1 )) 2 "$PV_title"
    }

    function push_log_message() {
        local ccc=""
        [ $log_message_counter -gt 1 ] && ccc=" (x${log_message_counter})"
        XY 0 $log_message_y "${DEF}$just_big_enough_string${DEF}"
        XY $(($window_width/2 - ${#log_message}/2)) $log_message_y "${DGRY}$log_message$ccc${DEF}"
        XY 0 $(($log_message_y + 2)) "${DEF}$just_big_enough_string${DEF}"
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

    function put_log_message() {
        log_message=${1}
        local ccc=""
        XY 0 $(($log_message_y + 2)) "${DEF}$just_big_enough_string${DEF}"
        XY $(($window_width/2 - ${#log_message}/2)) $(($log_message_y + 2)) "${pure_white_fore}$log_message$ccc${DEF}"
    }
#-----------------------------------------------------------------------



# Отрисовка самой карты
#-----------------------------------------------------------------------
    function redraw_map() {
        clear

        draw_dungeon_floor_GUI

        local i
        local j
        for ((i=0; i<${room_height}; i++)); do
            for ((j=0; j< ${room_width}; j++)); do
                if [ ${seen[$(($i * $room_width + $j))]} -eq 1 ]; then
                    update_point $j $i
                fi
            done
        done

        update_player_position
    }

    function update_point() {
        local i=${1}
        local j=${2}
        
        local point=${dungeon_map[$(($j * $room_width + $i))]}
        local mod=${basic_gray_back}
        local in_vision=0
        [[ $point =~ [\ ] ]] && mod=${DEF}
        if (( ($player_new_x - $i) * ($player_new_x - $i) + ($player_new_y - $j) * ($player_new_y - $j) < ${player_stats["vision_radius"]} * ${player_stats["vision_radius"]} )); then 
            mod="${light_gray_back}"
            in_vision=1
        fi
        [[ $point =~ [\.\#\<\>] ]] && mod=${mod}${basic_gray_fore}
        [[ $point =~ [\*] ]] && mod=${mod}${BCYN}
        [[ $point =~ [\[] ]] && mod=${mod}${door_fore}

        if [[ ${dungeon_items[$(($j * $room_width + $i))]} != "" ]]; then mod="${mod}${brown_item_fore}"; point=","; fi
        
        if [[ ${dungeon_entities[$(($j * $room_width + $i))]} != "" && $in_vision == 1 ]]; then 
            local entity_id=${dungeon_entities[$(($j * $room_width + $i))]}
            local symbol=$(get_entity_param ${entity_id} symbol)
            local color=$(get_entity_param ${entity_id} color)
            mod="${mod}\\${color}"
            point="${symbol}";
        fi

        if [[ $player_x == $i && $player_y == $j ]]; then mod=${light_gray_back}${player_blue}; point="@"; fi
        [[ $point == " " ]] && point='\x20'
        [ ${seen[$(($j * $room_width + $i))]} -eq 1 ] && draw_with_offset $i $j "${mod}${point}${DEF}"
        [ ${seen[$(($j * $room_width + $i))]} -eq 0 ] && draw_with_offset $i $j "${DEF}\x20${DEF}" #\x20
    }

    function reveal_map() {
        draw_dungeon_floor_GUI
        
        local j
        local i
        for ((j=0; j<${room_height}; j++)); do
            for ((i=0; i<${room_width}; i++)); do
                seen[$(($j * $room_width + $i))]=1
                update_point $i $j
            done
        done

        update_player_position
    }
#-----------------------------------------------------------------------


# Инвентарь
#-----------------------------------------------------------------------

    # Отрисовка и выбор
    #-----------------------------------------------------------------------
        function draw_equipment_menu() {
            clear 
            draw_dungeon_floor_GUI
            for (( i=$x_offset; i<${window_width}/2; i++)); do
                XY $i 4 "${light_gray_back} "
            done
            local equipment_name="Equipment"
            XY $(( ${window_width}/4 - ${#equipment_name}/2 + $x_offset/2 )) 4 "${light_gray_back}${DGRY}$equipment_name${DEF}"
            for (( i=${window_width}/2; i<${window_width}-$x_offset; i++)); do
                XY $i 4 "${BDGRY} "
            done
            local inventory_name="Inventory"
            XY $(( ${window_width}/4*3 - ${#inventory_name}/2 - $x_offset/2 )) 4 "${BDGRY}${pure_white_fore}$inventory_name${DEF}"

            letters_to_items=()
            letters_to_items_xx=()
            letters_to_items_yy=()
            
            draw_equipment_piece 7 "first_hand" "Main Hand" 'a'
            draw_equipment_piece 11 "second_hand" "Second Hand" 'b'
            draw_equipment_piece 15 "helmet" "Head" 'c'
            draw_equipment_piece 19 "chestplate" "Body" 'd'
            draw_equipment_piece 23 "boots" "Legs" 'e'
            draw_equipment_piece 27 "misc" "Misc" 'f'
        }

        function draw_equipment_piece() {
            local yy=${1}
            local type_id="${2}"
            local type_name="${3}"
            local letter_for_equip="${4}"
            wide_string_for_empty_item="________________________________________"
            base_equipment_xx=$(($window_width/5*2 + 12))
            
            XY $(($base_equipment_xx - ${#wide_string_for_empty_item}/2 - 20 + 16 + 2)) $yy ":"
            XY $(($base_equipment_xx - ${#wide_string_for_empty_item}/2)) $yy ${wide_string_for_empty_item}
            if [[ ${equipment[$type_id]} != "" ]]; then
                type_name="${basic_brown_fore}$type_name${DEF}"
                XY $(($base_equipment_xx - ${#wide_string_for_empty_item}/2 - 20 - 4)) $yy "($letter_for_equip)"

                letters_to_items[$letter_for_equip]=$type_id
                letters_to_items_xx[$letter_for_equip]=$(($base_equipment_xx - ${#wide_string_for_empty_item}/2 - 20 - 4))
                letters_to_items_yy[$letter_for_equip]=$yy

                local item
                IFS=' ' read -r -a item <<< "${equipment[$type_id]}"
                local item_name=$(get_item_param ${item[0]} name)
                [ ${item[1]} -gt 1 ] && item_name="$item_name (x${item[1]})"
                XY $(($base_equipment_xx - ${#item_name}/2)) $yy "${UND}$item_name${DEF}"
            fi
            XY $(($base_equipment_xx - ${#wide_string_for_empty_item}/2 - 20)) $yy "$type_name"
        }

        function equipment_cycle() {
            while [[ $cur_screen == "equipment_menu" ]]; do
                update_time
                read -t0.1 -n1 input; 
                [[ $input != "" && ${translit[$input]} != "" ]] && input=${translit[$input]}
                case $input in
                    "i") close_items_menu;;
                    "E") open_inventory_menu;;
                    [a-z]) choose_item_letter_in_items_menu $input "equipment";;
                esac
            done
        }

        function draw_inventory_menu() {
            clear 
            draw_dungeon_floor_GUI
            for (( i=$x_offset; i<${window_width}/2; i++)); do
                XY $i 4 "${BDGRY} "
            done
            local equipment_name="Equipment"
            XY $(( ${window_width}/4 - ${#equipment_name}/2 + $x_offset/2 )) 4 "${BDGRY}${pure_white_fore}$equipment_name${DEF}"
            for (( i=${window_width}/2; i<${window_width}-$x_offset; i++)); do
                XY $i 4 "${light_gray_back} "
            done
            local inventory_name="Inventory"
            XY $(( ${window_width}/4*3 - ${#inventory_name}/2 - $x_offset/2 )) 4 "${light_gray_back}${DGRY}$inventory_name${DEF}"

            local cur_category=-1
            local yy=6
            local xx=$(($window_width/3))
            local letter_index=0
            letters_to_items=()
            letters_to_items_xx=()
            letters_to_items_yy=()
            local iii
            for ((iii=0; iii<${#inventory[@]} && $yy < $log_message_y-3; iii++ )); do
                local item
                local letter=${alphabet[$letter_index]}
                IFS=' ' read -r -a item <<< "${inventory[$iii]}"
                local item_category=$(get_item_param ${item[0]} category)
                if [[ $item_category != $cur_category ]]; then
                    ((yy++))
                    cur_category=$item_category
                    local item_category_name=${categories_names[$cur_category]}
                    XY $xx $yy "${basic_brown_fore}$item_category_name${DEF}"; ((yy += 2))
                fi
                local item_name=$(get_item_param ${item[0]} name)
                [ ${item[1]} -gt 1 ] && item_name="$item_name (x${item[1]})"
                letters_to_items[$letter]=$iii
                letters_to_items_xx[$letter]=$(($xx - 4))
                letters_to_items_yy[$letter]=$yy
                XY $(($xx - 4)) $yy "${DEF}($letter) ${DEF}$item_name${DEF}"; ((yy += 2)); ((letter_index++))
            done
        }

        function inventory_cycle() {
            while [[ $cur_screen == "inventory_menu" ]]; do
                update_time
                read -t0.1 -n1 input; 
                [[ $input != "" && ${translit[$input]} != "" ]] && input=${translit[$input]}
                case $input in
                    "i") close_items_menu;;
                    "E") open_equipment_menu;;
                    [a-z]) choose_item_letter_in_items_menu $input "inventory";;
                esac
            done
        }

        function dropped_items_cycle() {
            local xx=${1}
            local yy=${2}
            while [[ $cur_screen == "dropped_items_menu" ]]; do
                update_time
                read -t0.1 -n1 input; 
                [[ $input != "" && ${translit[$input]} != "" ]] && input=${translit[$input]}
                case $input in
                    "i") close_items_menu;;
                    "E") open_inventory_menu;;
                    [a-z]) choose_item_letter_in_items_menu $input "dropped_items,$xx,$yy";;
                esac
            done
        }

        function draw_dropped_items_menu() {
            clear 
            draw_dungeon_floor_GUI
            for (( i=$x_offset; i<${window_width}-$x_offset; i++)); do
                XY $i 4 "${BDGRY} "
            done
            local menu_name="Dropped Items"
            XY $(( ${window_width}/2 - ${#equipment_name}/2 )) 4 "${BDGRY}${pure_white_fore}$menu_name${DEF}"

            local dropped_items
            IFS=',' read -r -a dropped_items <<< "${dungeon_items[$(( ${2} * ${room_width} + ${1} ))]}"

            local cur_category=-1
            local yy=6
            local xx=$(($window_width/3))
            local letter_index=0
            letters_to_items=()
            letters_to_items_xx=()
            letters_to_items_yy=()
            local iii
            for ((iii=0; iii<${#dropped_items[@]} && $yy < $log_message_y-3; iii++ )); do
                local item
                local letter=${alphabet[$letter_index]}
                IFS=' ' read -r -a item <<< "${dropped_items[$iii]}"
                local item_category=$(get_item_param ${item[0]} category)
                if [[ $item_category != $cur_category ]]; then
                    ((yy++))
                    cur_category=$item_category
                    local item_category_name=${categories_names[$cur_category]}
                    XY $xx $yy "${basic_brown_fore}$item_category_name${DEF}"; ((yy += 2))
                fi
                local item_name=$(get_item_param ${item[0]} name)
                [ ${item[1]} -gt 1 ] && item_name="$item_name (x${item[1]})"
                letters_to_items[$letter]=$iii
                letters_to_items_xx[$letter]=$(($xx - 4))
                letters_to_items_yy[$letter]=$yy
                XY $(($xx - 4)) $yy "${DEF}($letter) ${DEF}$item_name${DEF}"; ((yy += 2)); ((letter_index++))
            done
        }

        function choose_item_letter_in_items_menu() {
            local id=${letters_to_items[${1}]}
            local xxx=${letters_to_items_xx[${1}]}
            local yyy=${letters_to_items_yy[${1}]}
            local menu="${2}"
            if [[ $id != "" ]]; then

                XY $xxx $yyy "${MGN}(${1})${DEF}"

                local xx=$(($window_width - ${x_offset} - 20 - 2))
                local yy=$(($window_height/2 - 10))
                local item=$(get_item_from_menu ${id} ${menu})
                IFS=' ' read -r -a item <<< "$item"
                declare -a item_actions
                item_actions=()
                IFS=',' read -r -a item_actions <<< "$(get_item_param ${item[0]} actions)"
                add_special_item_actions ${item} ${menu}
                item_actions[${#item_actions[@]}]='abort_choosing'

                XY $xx $yy "${basic_gray_back}                    ${DEF}"
                XY $xx $(($yy + 1)) "${basic_gray_back} ${DEF}"
                XY $(($xx + 19)) $(($yy + 1)) "${basic_gray_back} ${DEF}"; ((yy += 2))
                for ((i=0; i<${#item_actions[@]}; i++)); do
                    local item_action
                    IFS=' ' read -r -a item_action <<< "${item_actions[$i]}"
                    XY $(($xx)) $yy "${basic_gray_back} ${DEF} $(($i + 1))) ${item_actions_names[${item_action[0]}]}"
                    XY $(($xx + 19)) $yy "${basic_gray_back} ${DEF}"
                    XY $xx $(($yy + 1)) "${basic_gray_back} ${DEF}"
                    XY $(($xx + 19)) $(($yy + 1)) "${basic_gray_back} ${DEF}"; ((yy += 2))
                done
                XY $xx $yy "${basic_gray_back}                    ${DEF}"
                
                flag=0
                while [[ $flag == 0 ]]; do
                    read -t0.1 -n1 input; 
                    [[ $input != "" && ${translit[$input]} != "" ]] && input=${translit[$input]}
                    local i
                    local j
                    for ((i=0; i<${#item_actions[@]}; i++)); do
                        if [[ $input == $(($i + 1)) ]]; then
                            # Зарисовка чёрным обратно
                            local xx=$(($window_width - ${x_offset} - 20 - 2))
                            local yy=$(($window_height/2 - 10))
                            XY $xx $yy "${DEF}                    "
                            XY $xx $(($yy+1)) "${DEF}                    "; ((yy++))
                            for ((j=0; j<${#item_actions[@]}; j++)); do
                                XY $xx $yy "${DEF}                    "
                                XY $xx $(($yy+1)) "${DEF}                    "; ((yy += 2))
                            done
                            XY $xx $yy "${DEF}                    "
                            XY $xx $(($yy+1)) "${DEF}                    "

                            XY $xxx $yyy "${DEF}(${1})${DEF}"

                            # Выполнение действия с передачей менюшки и айдишника
                            local item_action
                            IFS=' ' read -r -a item_action <<< "${item_actions[$i]}"
                            local args=${item_action[@]:1}
                            ${item_action[0]} "$id" "$menu" "${args}"

                            flag=1

                            local xx=$(($window_width - ${x_offset} - 20 - 2))
                            local yy=$(($window_height/2 - 10))
                            
                            break;
                        fi
                    done
                done
            fi
        }

        function get_item_from_menu() {
            case ${2} in
                "inventory") echo ${inventory[${1}]};;
                "equipment") echo ${equipment[${1}]};;
                *) local menu
                IFS=',' read -r -a menu <<< "${1}"
                if [[ ${menu[0]} == "dropped_items" ]]; then 
                    echo "${dungeon_items[$(( ${menu[2]} * ${room_width} + ${menu[1]} ))]}"
                fi
                ;;
            esac
        }

        function add_special_item_actions() {
            local item=$(get_item_from_menu ${1} ${2})
            IFS=' ' read -r -a item <<< "$item"

            case ${2} in
                "inventory") 
                    [[ $(get_item_param ${item[0]} slot) != "" ]] && item_actions[${#item_actions[@]}]='equip_item'
                    [[ $(get_item_param ${item[0]} undroppable) != "" ]] && item_actions[${#item_actions[@]}]='drop_item'
                    ;;
                "equipment") 
                    [[ $(get_item_param ${item[0]} undroppable) != "" ]] && item_actions[${#item_actions[@]}]='deequip_item'
                    ;;
                *) 
                    local menu
                    IFS=',' read -r -a menu <<< "${1}"
                    if [[ ${menu[0]} == "dropped_items" ]]; then 
                        item_actions=('pick_up_item')
                    fi
                    ;;
            esac
        }
    #-----------------------------------------------------------------------

    # Действия с предметами
    #-----------------------------------------------------------------------
        function add_item_to_inventory() {
            local new_item=${1}
            # echo "Add: ${new_item}" >> log_test.txt
            IFS=' ' read -r -a new_item <<< "${1}"
            
            local new_item_category=$(get_item_param ${new_item[0]} category)
            local place_to_push=${#inventory[@]}

            for ((i=0; i<${#inventory[@]}; i++)); do
                local item
                IFS=' ' read -r -a item <<< "${inventory[$i]}"
                local item_category=$(get_item_param ${item[0]} category)
                
                if [[ "${item[0]}" == "${new_item[0]}" ]]; then
                    inventory[$i]="${item[0]} $((${item[1]} + ${new_item[1]}))"
                    return
                fi

                if [[ $item_category > $new_item_category && $place_to_push == ${#inventory[@]} ]]; then 
                    place_to_push=$i
                fi
            done
            local old_inv=("${inventory[@]}")
            for ((i=0; i<$place_to_push; i++)); do
                inventory[$i]=${old_inv[$i]}
            done
            inventory[$place_to_push]=${1}
            for ((i=$(($place_to_push+1)); i<=${#old_inv[@]}; i++)); do
                inventory[$i]=${old_inv[$(($i - 1))]}
            done
        }

        function delete_item_from_inventory() {
            local item_id=${1}
            local del_amount=${2}
            
            local item
            IFS=' ' read -r -a item <<< "${inventory[$item_id]}"

            ((item[1] -= $del_amount))

            if [[ ${item[1]} -le 0 ]]; then
                local old_inv=("${inventory[@]}")
                inventory=()
                local ii
                for ((ii=0; ii<$item_id; ii++)); do
                    inventory[$ii]=${old_inv[$ii]}
                done
                for ((ii=$(($item_id+1)); ii<${#old_inv[@]}; ii++)); do
                    inventory[$(($ii - 1))]=${old_inv[$(($ii))]}
                done
            else
                inventory[$item_id]="${item[@]}"
            fi
        }

        function drop_item() {
            local item
            IFS=' ' read -r -a item <<< "${inventory[$item_id]}"

            add_item_to_floor "${inventory[$item_id]}" $player_x $player_y

            delete_item_from_inventory ${1} 1

            draw_inventory_menu

            push_log_message "You dropped $(get_item_param ${item[0]} name)"
        }

        function add_item_to_floor() {
            local item="${1}"
            local xx=${2}
            local yy=${3}

            dungeon_items[$(( $yy * $room_width + $xx ))]="${dungeon_items[$(( $yy * $room_width + $xx ))]}${item},"
        }

        function deequip_item_from_slot() {
            local slot=${1}

            if [[ ${equipment[$slot]} != "" ]]; then
                update_player_stats_by_item "${equipment[$slot]}" 1
                add_item_to_inventory "${equipment[$slot]}"
                equipment[$slot]=""
            fi
        }

        function equip_item_to_slot() {
            local slot=${1}
            local item=${2}

            equipment[$slot]="$item"

            update_player_stats_by_item "$item" 0 
        }

        function update_player_stats_by_item() {
            local item
            IFS=' ' read -r -a item <<< "${1}"
            local mod=1
            [ ${2} == 1 ] && mod=-1

            if [[ $(get_item_param ${item[0]} vision_radius_mod) ]]; then
                ((player_stats["vision_radius"] += $mod * $(get_item_param ${item[0]} vision_radius_mod) ))
            fi
            if [[ $(get_item_param ${item[0]} PV) ]]; then
                ((player_stats["PV"] += $mod * $(get_item_param ${item[0]} PV) ))
            fi
            if [[ $(get_item_param ${item[0]} DV) ]]; then
                ((player_stats["DV"] += $mod * $(get_item_param ${item[0]} DV) ))
            fi
            if [[ $(get_item_param ${item[0]} base_accuracy) ]]; then
                ((player_stats["base_accuracy"] += $mod * $(get_item_param ${item[0]} base_accuracy) ))
            fi
        }

        function deequip_item() {
            local slot=${1}
            local item
            IFS=' ' read -r -a item <<< "${equipment[$slot]}"
            
            if [[ ${equipment[$slot]} != "" ]]; then
                deequip_item_from_slot $slot
            fi

            draw_equipment_menu
            push_log_message "You deequipped $(get_item_param ${item[0]} name)."
        }

        function equip_item() {
            local item_id=${1}

            local item
            IFS=' ' read -r -a item <<< "${inventory[$item_id]}"

            local slot=$(get_item_param ${item[0]} slot)
            
            if [[ ${equipment[$slot]} != "" ]]; then
                deequip_item_from_slot $slot
                IFS=' ' read -r -a item <<< "${inventory[$item_id]}"
            fi

            equip_amount=1
            [[ ${items[${item[0]}, max_equip]} != "" ]] && equip_amount=$(get_item_param ${item[0]} max_equip)
            [[ $equip_amount == -1 ]] && equip_amount=${item[1]}
            equip_item_to_slot $slot "${item[0]} $equip_amount"
            delete_item_from_inventory $item_id $equip_amount

            draw_inventory_menu
            push_log_message "You equipped $(get_item_param ${item[0]} name)."
        }

        function pick_up_item() {
            local item_id=${1}
            local menu=${2}
            IFS=',' read -r -a menu <<< "${menu}"
            if [[ ${menu[0]} == "dropped_items" ]]; then 
                local dropped_items
                IFS=',' read -r -a dropped_items <<< "${dungeon_items[$((  ${menu[2]} * ${room_width} +  ${menu[1]} ))]}"
                add_item_to_inventory "${dropped_items[${item_id}]}"

                local item=${dropped_items[${item_id}]}
                IFS=' ' read -r -a item <<< "${item}"

                local new_dropped_items=""
                local i
                for ((i=0; i<$item_id; i++)); do
                    new_dropped_items="${new_dropped_items}${dropped_items[$i]},"
                done
                for ((i=$item_id+1; i<${#dropped_items[@]}; i++)); do
                    new_dropped_items="${new_dropped_items}${dropped_items[$i]},"
                done

                dungeon_items[$((  ${menu[2]} * ${room_width} +  ${menu[1]} ))]="$new_dropped_items"

                draw_dropped_items_menu ${menu[1]} ${menu[2]}

                if [[ "$new_dropped_items" == "" ]]; then close_items_menu; fi

                push_log_message "You picked up $(get_item_param ${item[0]} name)"
            fi
        }

        function abort_choosing() {
            just_do_nothing
        }

        function just_do_nothing() {
            local wow_it_just_did_nothing=1
        }

        function smth() {
            push_log_message "Wow, it just did something!"
        }

        function drink_potion() {
            # echo "Drink" >> log_test.txt

            local item_id=${1}
            local menu=${2}
            local action
            IFS=' ' read -r -a action <<< "${3}"
            IFS=',' read -r -a menu <<< "${menu}"
            if [[ ${menu[0]} == "inventory" ]]; then 
                local item
                IFS=' ' read -r -a item <<< "${inventory[$item_id]}"

                local mess="You drank $( get_item_param ${item[0]} name ). $( get_item_param ${item[0]} desc )"

                ${action[0]} ${action[@]:1}

                delete_item_from_inventory $item_id 1

                draw_inventory_menu

                push_log_message $mess
            fi
        }

        function heal_player() {
            local amount=${1}
            # echo "Healed for ${amount}" >> log_test.txt
            ((player_stats["hp"] += $amount))
            if (( ${player_stats["hp"]} > ${player_stats["max_hp"]} )); then
                player_stats["hp"]=${player_stats["max_hp"]}
            fi

            update_player_hp_GUI
        }
    #-----------------------------------------------------------------------

    # Загрузка прототипов, получение свойств предметов
    #-----------------------------------------------------------------------
        function load_items_prototypes() {
            # echo "" > log_test.txt
            local items_files
            IFS=' ' read -r -a items_files <<< "$(ls ./Items/*.ddditems | sed -z 's/\n/ /g')"
            local cur_id
            
            local i
            for ((i=0; i<${#items_files[@]}; i++)); do
                local file=${items_files[$i]}

                while read line; do
                    line=$(echo $line | tr -d '\r\n')
                    IFS=' ' read -r -a param <<< "$line"
                    local param_name=${param[0]}
                    if [[ $param_name == "id" ]]; then
                        cur_id=${param[1]}
                        items["$cur_id, proto"]="$cur_id"
                        continue
                    elif [[ $param_name == "category" ]]; then
                        items_prototypes["${cur_id}, ${param_name}"]=${categories_ids[${param[1]}]}
                        continue
                    elif [[ $param_name == "DL" ]]; then
                        DL_items_tables[${param[1]}]="${DL_items_tables[${param[1]}]} $cur_id"
                    fi
                    items_prototypes["$cur_id, $param_name"]=${param[@]:1}
                done < $file
            done
        }

        function check_item_exists() {
            # local item=${1}
            # IFS=' ' read -r -a item <<< "${1}"

            # if [[ "${items[${item[0]}]}" != "" ]]; then
            #     echo ${1}
            #     return
            # fi

            # [[ ${items_prototypes[${item[0]}, name]} == "" ]] && echo "err, there are no ${item[0]} in protos" >> log.txt

            # items[${item[0]}, proto]="${item[0]}"

            echo ${1}
        }

        function get_item_param() {
            local item_id="${1}"
            local param="${2}"

            if [[ "${items[${item_id}, ${param}]}" != "" ]]; then
                echo "${items[${item_id}, ${param}]}"
                return
            fi

            local proto="${items[${item_id}, proto]}"

            # [[ ${items_prototypes[${proto}, ${param}]} == "" ]] && echo "err, there are no $param in $proto params in protos" >> log.txt

            echo "${items_prototypes[${proto}, ${param}]}"
        }

        function generate_new_item_case_from_proto() {
            local proto=${1}
            local new_item_id=${1}
            local new_item_name="${items_prototypes[$proto, name]}"
            local base_dmg=""
            local DV=""
            local PV=""
            local base_accuracy=""
            
            if [[ ${items_prototypes[$proto, base_dmg]} != "" ]]; then
                IFS=' ' read -r -a base_dmg <<< "${items_prototypes[$proto, base_dmg]}"
                if [[ ${items_prototypes[$proto, base_dmg_range]} != "" ]]; then
                    local base_dmg_range
                    IFS=' ' read -r -a base_dmg_range <<< "${items_prototypes[$proto, base_dmg_range]}"
                    ((base_dmg[2] += $(get_random_range ${base_dmg_range[0]} ${base_dmg_range[1]}) ))
                fi
                if [[ ${items_prototypes[$proto, base_accuracy_range]} != "" ]]; then
                    local base_accuracy_range
                    IFS=' ' read -r -a base_accuracy_range <<< "${items_prototypes[$proto, base_accuracy_range]}"
                    ((base_dmg[3] += $(get_random_range ${base_accuracy_range[0]} ${base_accuracy_range[1]}) ))
                fi
                new_item_id="${new_item_id}_${base_dmg[0]}d${base_dmg[1]}"
                new_item_name="${new_item_name} (${base_dmg[0]}d${base_dmg[1]}"
                if [ ${base_dmg[2]} -gt 0 ]; then new_item_id="${new_item_id}+"; new_item_name="${new_item_name}+"; fi
                if [ ${base_dmg[2]} -ne 0 ]; then new_item_id="${new_item_id}${base_dmg[2]}"; new_item_name="${new_item_name}${base_dmg[2]}"; fi
                new_item_id="${new_item_id}&"
                new_item_name="${new_item_name}, "
                if [ ${base_dmg[3]} -gt 0 ]; then new_item_id="${new_item_id}+"; new_item_name="${new_item_name}+"; fi
                    new_item_id="${new_item_id}${base_dmg[3]}"; new_item_name="${new_item_name}${base_dmg[3]}";
                new_item_name="${new_item_name})"
            fi

            if [[ ${items_prototypes[$proto, base_accuracy]} != "" || ${items_prototypes[$proto, base_accuracy]} != "" ]]; then
                base_accuracy="${items_prototypes[$proto, base_accuracy]}"
                local base_accuracy_range
                if [[ ${items_prototypes[$proto, base_accuracy_range]} != "" ]]; then
                    IFS=' ' read -r -a base_accuracy_range <<< "${items_prototypes[$proto, base_accuracy_range]}"
                    ((base_accuracy += $(get_random_range ${base_accuracy_range[0]} ${base_accuracy_range[1]}) ))
                fi
                new_item_id="${new_item_id}_${base_accuracy}"
                new_item_name="${new_item_name} (${base_accuracy})"
            fi

            if [[ ${items_prototypes[$proto, DV]} != "" || ${items_prototypes[$proto, PV]} != "" ]]; then
                DV="${items_prototypes[$proto, DV]}"
                PV="${items_prototypes[$proto, PV]}"
                local DV_range
                local PV_range
                if [[ ${items_prototypes[$proto, DV_range]} != "" ]]; then
                    IFS=' ' read -r -a DV_range <<< "${items_prototypes[$proto, DV_range]}"
                    ((DV += $(get_random_range ${DV_range[0]} ${DV_range[1]}) ))
                fi
                if [[ ${items_prototypes[$proto, PV_range]} != "" ]]; then
                    IFS=' ' read -r -a PV_range <<< "${items_prototypes[$proto, PV_range]}"
                    ((PV += $(get_random_range ${PV_range[0]} ${PV_range[1]}) ))
                fi
                new_item_id="${new_item_id}_[${DV}&${PV}]"
                new_item_name="${new_item_name} [${DV}, ${PV}]"
            fi

            items["${new_item_id}, proto"]="$proto"
            items["${new_item_id}, name"]="$new_item_name"
            [[ $base_dmg != "" ]] && items["$new_item_id, base_dmg"]="${base_dmg[@]}"
            [[ $DV != "" ]] && items["$new_item_id, DV"]="${DV}"
            [[ $PV != "" ]] && items["$new_item_id, PV"]="${PV}"
            [[ $base_accuracy != "" ]] && items["$new_item_id, base_accuracy"]="${base_accuracy}"

            new_item_generated="${new_item_id}"
        }

        function generate_item_from_proto() {
            local item_id=${1}
            generate_new_item_case_from_proto "$item_id"
            local amount=1
            if [[ ${items_prototypes[$item_id, amount_range]} != "" ]]; then
                local range
                IFS=' ' read -r -a range <<< "${items_prototypes[$item_id, amount_range]}"
                amount=$( get_random_range ${range[0]} ${range[1]} )
            fi

            new_item_generated="$new_item_generated $amount"
            # echo "GenProto:   $new_item_generated" >> log_test.txt
        }

        function generate_item_from_loot_table() {
            local DL=${1}
            local loot_table=""
            local i
            for ((i=$DL; i>0; i--)); do
                loot_table="$loot_table ${DL_items_tables[$DL]}"
            done
            IFS=' ' read -r -a loot_table <<< "${loot_table}"

            local proto=${loot_table[$((RANDOM % ${#loot_table[@]}))]}
            generate_new_item_case_from_proto "$proto"
            local amount=1
            if [[ ${items_prototypes[$proto, amount_range]} != "" ]]; then
                local range
                IFS=' ' read -r -a range <<< "${items_prototypes[$proto, amount_range]}"
                amount=$( get_random_range ${range[0]} ${range[1]} )
            fi

            new_item_generated="$new_item_generated $amount"
            # echo "GenTable:   $new_item_generated" >> log_test.txt
        }
    #-----------------------------------------------------------------------

#-----------------------------------------------------------------------



# Враги и прочие сучности
#-----------------------------------------------------------------------

    # Генерация
    #-----------------------------------------------------------------------
        function load_entities_prototypes() {
            local entities_files
            IFS=' ' read -r -a entities_files <<< "$(ls ./Entities/*.dddentities | sed -z 's/\n/ /g')"
            local cur_id
            
            local i
            for ((i=0; i<${#entities_files[@]}; i++)); do
                local file=${entities_files[$i]}

                while read line; do
                    line=$(echo $line | tr -d '\r\n')
                    IFS=' ' read -r -a param <<< "$line"
                    local param_name=${param[0]}
                    if [[ $param_name == "id" ]]; then
                        cur_id=${param[1]}
                        continue
                    elif [[ $param_name == "DL" ]]; then
                        DL_entities_tables[${param[1]}]="${DL_entities_tables[${param[1]}]} $cur_id"
                    fi
                    entities_prototypes["$cur_id, $param_name"]=${param[@]:1}
                done < $file
            done
        }

        function generate_new_entity_case_from_proto() {
            local proto=${1}
            local new_entity_name="${entities_prototypes[$proto, name]}"
            local base_dmg=""
            local DV=""
            local PV=""
            local max_hp=""
            
            if [[ ${entities_prototypes[$proto, max_hp]} != "" ]]; then
                IFS=' ' read -r -a max_hp <<< "${entities_prototypes[$proto, max_hp]}"
                local max_hp_range
                if [[ ${entities_prototypes[$proto, max_hp_range]} != "" ]]; then
                    IFS=' ' read -r -a max_hp_range <<< "${entities_prototypes[$proto, max_hp_range]}"
                    ((max_hp += $(get_random_range ${max_hp_range[0]} ${max_hp_range[1]}) ))
                fi
            fi
            if [[ ${entities_prototypes[$proto, base_dmg]} != "" ]]; then
                IFS=' ' read -r -a base_dmg <<< "${entities_prototypes[$proto, base_dmg]}"
                local base_dmg_range
                if [[ ${entities_prototypes[$proto, base_dmg_range]} != "" ]]; then
                    IFS=' ' read -r -a base_dmg_range <<< "${entities_prototypes[$proto, base_dmg_range]}"
                    ((base_dmg[2] += $(get_random_range ${base_dmg_range[0]} ${base_dmg_range[1]}) ))
                fi
            fi
            if [[ ${entities_prototypes[$proto, DV]} != "" || ${entities_prototypes[$proto, PV]} != "" ]]; then
                DV="${entities_prototypes[$proto, DV]}"
                PV="${entities_prototypes[$proto, PV]}"
                local DV_range
                local PV_range
                if [[ ${entities_prototypes[$proto, DV_range]} != "" ]]; then
                    IFS=' ' read -r -a DV_range <<< "${entities_prototypes[$proto, DV_range]}"
                    ((DV += $(get_random_range ${DV_range[0]} ${DV_range[1]}) ))
                fi
                if [[ ${entities_prototypes[$proto, PV_range]} != "" ]]; then
                    IFS=' ' read -r -a PV_range <<< "${entities_prototypes[$proto, PV_range]}"
                    ((PV += $(get_random_range ${PV_range[0]} ${PV_range[1]}) ))
                fi
            fi

            entities_list["${entities_counter}, proto"]="$proto"
            entities_list["${entities_counter}, name"]="$new_entity_name"
            [[ $base_dmg != "" ]] && entities_list["$entities_counter, base_dmg"]="${base_dmg[@]}"
            [[ $DV != "" ]] && entities_list["$entities_counter, DV"]="${DV}"
            [[ $PV != "" ]] && entities_list["$entities_counter, PV"]="${PV}"
            if [[ $max_hp != "" ]]; then entities_list["$entities_counter, max_hp"]="${max_hp}"; entities_list["$entities_counter, hp"]="${max_hp}"; fi

            ((entities_counter++))
        }

        function generate_entity_from_proto() {
            local entity_id=${1}
            generate_new_entity_case_from_proto "$entity_id"

            dungeon_entities_list[${#dungeon_entities_list[@]}]=$(($entities_counter - 1))
        }

        function generate_entity_from_danger_table() {
            local DL=${1}
            local gen_table=""
            local i
            for ((i=$DL; i>0; i--)); do
                local ttt="${DL_entities_tables[$DL]}"
                gen_table="$gen_table ${ttt}"
            done
            IFS=' ' read -r -a gen_table <<< "${gen_table}"

            local proto=${gen_table[$((RANDOM % ${#gen_table[@]}))]}
            generate_new_entity_case_from_proto "$proto"

            dungeon_entities_list[${#dungeon_entities_list[@]}]=$(($entities_counter - 1))
        }

        function get_entity_param() {
            local entity_id="${1}"
            local param="${2}"

            if [[ "${entities_list[${entity_id}, ${param}]}" != "" ]]; then
                echo "${entities_list[${entity_id}, ${param}]}"
                return
            fi

            local proto="${entities_list[${entity_id}, proto]}"

            # [[ ${entities_prototypes[${proto}, ${param}]} == "" ]] && echo "err, there are no $param in $proto params in protos" >> log.txt

            echo "${entities_prototypes[${proto}, ${param}]}"
        }
    #-----------------------------------------------------------------------

    # Взаимодействие с ними
    #-----------------------------------------------------------------------
        function player_base_attack_enemy() {
            local entity=${1}
            local attack_message="You attacked $(get_entity_param $entity name)"
            local base_dmg=${player_stats["base_dmg"]}
            if [[ ${equipment["first_hand"]} != "" ]]; then
                local eq=${equipment["first_hand"]}
                IFS=' ' read -r -a eq <<< "$eq"
                [[ "$(get_item_param ${eq[0]} base_dmg)" != "" ]] && base_dmg="$(get_item_param ${eq[0]} base_dmg)"

                attack_message="${attack_message} with your $(get_item_param ${eq[0]} name)"
            else
                attack_message="${attack_message} with your bare hands"
            fi

            IFS=' ' read -r -a base_dmg <<< "$base_dmg"
            local dice_roll_attack=$((RANDOM % 20 + 1 + ${player_stats["base_accuracy"]} + ${base_dmg[3]} ))
            # echo "Attack roll: ${dice_roll_attack}, Enemy DV: $( get_entity_param $entity DV )" >> log_test.txt

            if (( $dice_roll_attack < $( get_entity_param $entity DV ) )); then
                attack_message="${attack_message} but missed!"
                push_log_message "$attack_message"
            else
                local dice_roll_damage=${base_dmg[2]}
                local i
                for ((i=0; i<${base_dmg[0]}; i++)); do
                    ((dice_roll_damage += $( get_random_range 1 ${base_dmg[1]} ) ))
                done
                ((dice_roll_damage -= $( get_entity_param $entity PV ) ))
                # echo "Damage roll: ${dice_roll_damage}" >> log_test.txt

                (( dice_roll_damage < 0 )) && dice_roll_damage=0

                attack_message="${attack_message} and hit it for ${dice_roll_damage} hp."

                push_log_message "$attack_message"

                damage_entity ${entity} $dice_roll_damage
            fi
        } 

        function damage_entity() {
            local entity=${1}
            local value=${2}

            change_entity_hp ${entity} $((-${dice_roll_damage}))

            if [[ $(get_entity_param ${entity} hp) -le 0 ]]; then
                local xx=$(get_entity_param ${entity} xx)
                local yy=$(get_entity_param ${entity} yy)
                if [[ $xx != "" && $yy != "" ]]; then
                    dungeon_entities[$(($yy * $room_width + $xx))]=""
                    update_point $xx $yy
                    push_log_message "$(get_entity_param ${entity} name) is killed."
                fi
            fi
        }

        function change_entity_hp() {
            local entity=${1}
            local value=${2}

            if [[ ${entities_list[${entity}, hp]} != "" ]]; then
                ((entities_list[${entity}, hp] += ${value}))
            fi
        }

        function enemy_base_attack_player() {
            local entity=${1}
            local attack_message="$(get_entity_param $entity name) attacked you"
            local base_dmg=$( get_entity_param ${entity} base_dmg )

            IFS=' ' read -r -a base_dmg <<< "$base_dmg"
            local dice_roll_attack=$((RANDOM % 20 + 1 + ${base_dmg[3]} ))
            # echo "Attack roll: ${dice_roll_attack}, Player DV: ${player_stats["DV"]}}" >> log_test.txt

            if (( $dice_roll_attack < ${player_stats["DV"]} )); then
                attack_message="${attack_message} but missed!"
                push_log_message "$attack_message"
            else
                local dice_roll_damage=${base_dmg[2]}
                local i
                for ((i=0; i<${base_dmg[0]}; i++)); do
                    ((dice_roll_damage += $( get_random_range 1 ${base_dmg[1]} ) ))
                done
                (( dice_roll_damage -= ${player_stats["PV"]} ))
                # echo "Damage roll: ${dice_roll_damage}" >> log_test.txt

                (( dice_roll_damage < 0 )) && dice_roll_damage=0

                attack_message="${attack_message} and hit for ${dice_roll_damage} hp."

                push_log_message "$attack_message"

                damage_player $dice_roll_damage
            fi
        }

        function damage_player() {
            local value=${1}
            (( player_stats["hp"] -= $value ))

            update_player_hp_GUI

            (( player_stats["hp"] <= 0 )) && player_has_died
        }
    #-----------------------------------------------------------------------

#-----------------------------------------------------------------------


# Действия игрока
#-----------------------------------------------------------------------

    # Движение
    #-----------------------------------------------------------------------
        function player_can_move_here() {
            if [[ ${dungeon_map[$(($player_new_y * $cur_room_width + $player_new_x))]} =~ [\.\*\<\>] ]]; then
                echo "1"
            else
                player_new_x=$player_x
                player_new_y=$player_y
                echo "0"
            fi
        }

        function is_tile_passable() {
            local flag=0
            [[ ${dungeon_map[$((${2} * $cur_room_width + ${1}))]} =~ [\.\*\<\>\[] ]] && flag=1
            [[ ${dungeon_entities[$((${2} * $cur_room_width + ${1}))]} != "" ]] && flag=0

            echo $flag
        }

        function is_enemy_here() {
            local flag=0
            local entity=${dungeon_entities[$((${2} * $cur_room_width + ${1}))]}
            if [[ $entity != "" ]]; then
                flag=1
                if [[ $(get_entity_param ${entity} friend) == 1 ]]; then
                    flag=0
                fi
            fi

            echo $flag
        }

        function update_player_position() {

            if [[ $(is_tile_passable $player_new_x $player_new_y) == 1 ]]; then
                left=$(($player_new_x - ${player_stats["vision_radius"]} - 2)); [ $left -lt 0 ] && left=0
                right=$(($player_new_x + ${player_stats["vision_radius"]} + 2)); [ $right -gt $(($room_width-1)) ] && right=$(($room_width-1))
                top=$(($player_new_y - ${player_stats["vision_radius"]} - 2)); [ $top -lt 0 ] && top=0
                bottom=$(($player_new_y + ${player_stats["vision_radius"]} + 2)); [ $bottom -gt $(($room_height-1)) ] && bottom=$(($room_height-1))

                player_x=$player_new_x
                player_y=$player_new_y

                local i
                local j
                for ((i=$left; i<=$right; i++)) do
                    for ((j=$top; j<=$bottom; j++)) do
                        if (( ($player_new_x - $i) * ($player_new_x - $i) + ($player_new_y - $j) * ($player_new_y - $j) < ${player_stats["vision_radius"]} * ${player_stats["vision_radius"]} )); then 
                            #mod="$mod${BLYLW}${DGRY}"
                            mod="${light_gray_back}"
                            seen[$(($j * $cur_room_width + $i))]=1
                        fi
                        update_point $i $j
                    done
                done
            elif [[ $(is_enemy_here $player_new_x $player_new_y) == 1 ]]; then
                local entity=${dungeon_entities[$((${player_new_y} * $cur_room_width + ${player_new_x}))]}
                player_base_attack_enemy $entity
                # push_log_message "You bummed into $(get_entity_param ${entity} name)."
                player_new_x=$player_x
                player_new_y=$player_y
            else
                [[ ${dungeon_map[$(($player_new_y * $cur_room_width + $player_new_x))]} =~ [\#] ]] && push_log_message "You bummed in the wall."
                player_new_x=$player_x
                player_new_y=$player_y
            fi
            
            new_turn
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

            new_turn
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

            new_turn
        }

        function skip_turn() {
            new_turn
        }
    #-----------------------------------------------------------------------

    # Смотрение
    #-----------------------------------------------------------------------
        function look_at_something() {
            player_can_move=0
            targeting=1
            target_x=$player_x
            target_y=$player_y
            target_new_x=$target_x
            target_new_y=$target_y
            target_move="look_here"
            target_execution="end_looking"
            update_target_position
        }

        function look_here() {
            local i=$target_x
            local j=$target_y

            local mess="You looked at... something."
            local point=${dungeon_map[$(($j * $room_width + $i))]}
            if (( ($player_new_x - $i) * ($player_new_x - $i) + ($player_new_y - $j) * ($player_new_y - $j) < ${player_stats["vision_radius"]} * ${player_stats["vision_radius"]} )); then 
                mess="You looked at"
            else
                mess="You remembered that there was"
            fi
            [[ $point =~ [\ ] ]] && mess="You looked into the void. Void looked into you."
            [[ $point =~ [\.] ]] && mess="${mess} dungeon floor. Nothing special."
            [[ $point =~ [\#] ]] && mess="${mess} dungeon wall. Nothing special."
            [[ $point =~ [\*] ]] && mess="${mess} something that shouldn't be in release version."
            [[ $point =~ [\[] ]] && mess="${mess} opened door."
            [[ $point =~ [\<] ]] && mess="${mess} upstairs."
            [[ $point =~ [\>] ]] && mess="${mess} downstairs."

            if [[ ${dungeon_entities[$(($j * $room_width + $i))]} != "" ]]; then
                local entity=${dungeon_entities[$(($j * $room_width + $i))]}
                mess="You look at $(get_entity_param ${entity} name)."
                local hp=$(get_entity_param ${entity} hp)
                local max_hp=$(get_entity_param ${entity} max_hp)
                local stage=$(($hp * 4 / $max_hp))
                case $stage in
                    4) mess="${mess} It looks like it is at full health.";;
                    3) mess="${mess} It looks like it is slightly injured.";;
                    2) mess="${mess} It looks like it is moderately injured.";;
                    1) mess="${mess} It looks like it is severy damaged.";;
                    0) mess="${mess} It looks like it is close to death.";;
                esac
            fi

            [[ $player_x == $i && $player_y == $j ]] && mess="You looked at yourself. It's you, %%player_name%%!"
            [[ ${dungeon_items[$(($j * $room_width + $i))]} != "" ]] && mess="${mess} Also some items are lying here."

            [ ${seen[$(($j * $room_width + $i))]} -eq 0 ] && mess="You don't know, what is here."

            put_log_message "$mess"
        }

        function end_looking() {
            update_point $target_x $target_y

            push_log_message "You decided to stop looking"
        }
    #-----------------------------------------------------------------------

    # Действия с выбором цели
    #-----------------------------------------------------------------------
        function execute_target() {
            ( $target_execution )
            player_can_move=1
            targeting=0
            target_move=""
            target_execution=""
        }

        function update_target_position() {
            [ $target_new_x -ge $room_width ] && target_new_x=$(($room_width - 1))
            [ $target_new_y -ge $room_height ] && target_new_y=$(($room_height - 1))
            [ $target_new_x -lt 0 ] && target_new_x=0
            [ $target_new_y -lt 0 ] && target_new_y=0

            update_point $target_x $target_y

            target_x=$target_new_x
            target_y=$target_new_y

            local mod=${BRED}
            local point="${dungeon_map[$(($target_y * $cur_room_width + $target_x))]}"
            [ ${seen[$(($target_y * $cur_room_width + $target_x))]} -eq 0 ] && point=" "
            [[ $point == " " ]] && point='\x20'
            draw_with_offset $target_x $target_y "${DEF}${mod}${point}${DEF}"

            ( $target_move )
        }
    #-----------------------------------------------------------------------

    # Инвентарь
    #-----------------------------------------------------------------------
        function open_equipment_menu() {
            cur_screen="equipment_menu"
            updated=0
            draw_equipment_menu
            updated=1
            equipment_cycle
        }

        function close_items_menu() {
            cur_screen="the_dungeon"
            updated=0
            redraw_map
            updated=1
            # push_log_message "You decided to stop examining your things."
        }

        function open_inventory_menu() {
            cur_screen="inventory_menu"
            updated=0
            draw_inventory_menu
            updated=1
            inventory_cycle
        }

        function open_dropped_items_menu() {
            cur_screen="dropped_items_menu"
            updated=0
            draw_dropped_items_menu $player_x $player_y
            updated=1
            dropped_items_cycle "$player_x" "$player_y"
        }

        function pick_up_items() {
            local xx=${player_x}
            local yy=${player_y}

            local drop_items=${dungeon_items[$(($room_width * $yy + $xx))]}
            if [[ $drop_items == "" ]]; then
                push_log_message "There are no items to pick up."
                return
            fi

            open_dropped_items_menu
        }
    #-----------------------------------------------------------------------

    # Новый ход и прочая
    #-----------------------------------------------------------------------
        function new_turn() {
            ((turn_counter++))
            if (( $turn_counter % ${player_stats["hp_regeneration_rate"]} == 0 )); then
                if (( ${player_stats["hp"]} < ${player_stats["max_hp"]} )); then
                    ((player_stats["hp"] += 1))
                    update_player_hp_GUI
                fi
            fi

            local i
            # echo "turn: ${turn_counter}" >> log_test.txt
            for ((i=0; i<${#dungeon_entities_list[@]}; i++)); do
                local entity=${dungeon_entities_list[$i]}
                # echo "entity ${entity} hp $(get_entity_param $entity hp)" >> log_test.txt
                if (( $(get_entity_param $entity hp) > 0 )); then
                    process_entity $entity
                fi
            done
        }

        function find_next_step_from_point_to_point() {
            local x1=${1}
            local y1=${2}
            local x2=${3}
            local y2=${4}
            local max_steps=${5}

            local q=("${x1} ${y1} 0")
            declare -a local_checked
            declare -a local_parent
            local_parent[0]=0
            local q_pointer=0
            local q_size=1
            local ans=""
            while (($q_pointer < $q_size)); do
                local node
                IFS=' ' read -r -a node <<< "${q[$q_pointer]}"
                local xx=${node[0]}
                local yy=${node[1]}
                # echo "xx: $xx, yy: $yy" >> log_test.txt
                local_checked[$(($yy * $room_width + $xx))]=1
                if [[ $xx == $x2 && $yy == $y2 ]]; then
                    ans=$q_pointer
                    break
                fi
                if [ -z ${local_checked[$(($yy * $room_width + $xx + 1))]} ]; then if (( $( is_tile_passable $(($xx + 1)) $(($yy)) ) == 1 && ${node[2]} < $max_steps )); then q[$q_size]="$(($xx + 1)) $(($yy)) $((${node[2]} + 1))"; local_parent[$q_size]=$q_pointer; ((q_size++)); fi; fi
                if [ -z ${local_checked[$(($yy * $room_width + $xx - 1))]} ]; then if (( $( is_tile_passable $(($xx - 1)) $(($yy)) ) == 1 && ${node[2]} < $max_steps )); then q[$q_size]="$(($xx - 1)) $(($yy)) $((${node[2]} + 1))"; local_parent[$q_size]=$q_pointer; ((q_size++)); fi; fi
                if [ -z ${local_checked[$(( ($yy + 1) * $room_width + $xx))]} ]; then if (( $( is_tile_passable $(($xx)) $(($yy + 1)) ) == 1 && ${node[2]} < $max_steps )); then q[$q_size]="$(($xx)) $(($yy + 1)) $((${node[2]} + 1))"; local_parent[$q_size]=$q_pointer; ((q_size++)); fi; fi
                if [ -z ${local_checked[$(( ($yy - 1) * $room_width + $xx))]} ]; then if (( $( is_tile_passable $(($xx)) $(($yy - 1)) ) == 1 && ${node[2]} < $max_steps )); then q[$q_size]="$(($xx)) $(($yy - 1)) $((${node[2]} + 1))"; local_parent[$q_size]=$q_pointer; ((q_size++)); fi; fi
                
                ((q_pointer++))
            done

            if [[ $ans != "" ]]; then
                while [[ ${local_parent[$ans]} != 0 ]]; do
                    ans=${local_parent[$ans]}
                done

                local node
                IFS=' ' read -r -a node <<< "${q[$ans]}"

                echo "${node[0]} ${node[1]}"
            else
                echo ""
            fi
        }

        function process_entity() {
            local entity=${1}
            local xx=$(get_entity_param ${entity} xx)
            local yy=$(get_entity_param ${entity} yy)
            if [[ $xx != "" && $yy != "" ]]; then
                # echo "xx: $xx, player_x: $player_x, yy: $yy, player_y: $player_y" >> log_test.txt
                if (( ($xx - $player_x)*($xx - $player_x) + ($yy - $player_y)*($yy - $player_y) <= 4*4 )); then
                    # echo "entity_move: ${entity}" >> log_test.txt
                    local next_step=$( find_next_step_from_point_to_point ${xx} ${yy} ${player_x} ${player_y} 4 )
                    if [[ $next_step != "" ]]; then
                        IFS=' ' read -r -a next_step <<< "$next_step"

                        if [[ ${next_step[0]} == $player_x && ${next_step[1]} == $player_y ]]; then
                            enemy_base_attack_player $entity
                        else
                            entities_list["$entity, xx"]=${next_step[0]}
                            entities_list["$entity, yy"]=${next_step[1]}
                            dungeon_entities[$(($yy * $room_width + $xx))]=""
                            dungeon_entities[$(( ${next_step[1]} * $room_width + ${next_step[0]} ))]=$entity
                            update_point $xx $yy
                            update_point ${next_step[0]} ${next_step[1]}
                        fi
                    fi
                fi
            fi
        }
    #-----------------------------------------------------------------------

    # Смэрть
    #-----------------------------------------------------------------------
        declare -a death_screen
             death_screen[0]="    ■   ■    ■■■    ■   ■    "
             death_screen[1]="    ■   ■   ■   ■   ■   ■    "
             death_screen[2]="     ■ ■    ■   ■   ■   ■    "
             death_screen[3]="      ■     ■   ■   ■   ■    "
             death_screen[4]="      ■      ■■■     ■■■     "
             death_screen[5]="                             "
             death_screen[6]="■■■■    ■■■■■   ■■■■■   ■■■■ "
             death_screen[7]="■   ■     ■     ■       ■   ■"
             death_screen[8]="■   ■     ■     ■■■■    ■   ■"
             death_screen[9]="■   ■     ■     ■       ■   ■"
            death_screen[10]="■■■■    ■■■■■   ■■■■■   ■■■■ "
        function player_has_died() {
            clear
            cur_screen="death"
            window_width=$( tput cols  )
            window_height=$( tput lines )
            name_height=${#death_screen[@]}
            name_width=${#death_screen[0]}
            press_exit="Press Ctrl+C to exit"
            
            local i
            for ((i=0; i<${#death_screen[@]}; i++)); do
                XY $(($window_width / 2 - $name_width / 2)) $(($window_height / 2 - ${#death_screen[@]} / 2 - 3 + $i)) "\033[01;38;05;54m${death_screen[$i]}${DEF}"
            done

            XY $(($window_width / 2 - ${#press_exit} / 2)) $(($window_height / 2 + ${#death_screen[@]} / 2 + 3)) "$press_exit"
        }
    #-----------------------------------------------------------------------
#-----------------------------------------------------------------------



# Выход из программы, возврат курсора
#-----------------------------------------------------------------------
    function bye () {
        stty echo
        printf "${CON}${DEF}"
        clear
        exit 0
    }

    printf "${COF}"
    stty -echo
    clear
    trap bye 1 2 3 8 9 15
    trap - SIGALRM

    XY $window_width $window_height " "
#-----------------------------------------------------------------------



# Глобальные переменные
#-----------------------------------------------------------------------
    # echo "" > log.txt

    declare -a dungeon_map
    declare -a seen
    declare -a dungeon_entities
    declare -a dungeon_entities_list
    declare -a dungeon_items
    declare -a dungeon_floors_map
    declare -a dungeon_floors_seen
    declare -a dungeon_floors_pl_coords
    declare -a dungeon_floors_entities
    declare -a dungeon_floors_entities_list
    declare -a dungeon_floors_items

    dungeon_floor=0
    cur_dunger_level=1

    declare -a alphabet=( a b c d e f g h i j k l m n o p q r s t u v w x y z )
    declare -A translit=([й]="q" [ц]="w" [у]="e" [к]="r" [е]="t" [н]="y" [г]="u" [ш]="i" [щ]="o" [з]="p" [х]="[" [ъ]="]" [ф]="a" [ы]="s" [в]="d" [а]="f" [п]="g" [р]="h" [о]="j" [л]="k" [д]="l" [я]="z" [ч]="x" [с]="c" [м]="v" [и]="b" [т]="n" [ь]="m" [б]="," [ю]="."     [Й]="Q" [Ц]="W" [У]="E" [К]="R" [Е]="T" [Н]="Y" [Г]="U" [Ш]="I" [Щ]="O" [З]="P" [Х]="{" [Ъ]="}" [Ф]="A" [Ы]="S" [В]="D" [А]="F" [П]="G" [Р]="H" [О]="J" [Л]="K" [Д]="L" [Я]="Z" [Ч]="X" [С]="C" [М]="V" [И]="B" [Т]="N" [Ь]="M" [Б]="<" [Ю]=">")

    room_width=120
    room_height=30
    rm_min_size=5

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

    # Местоположение
    player_x=0
    player_y=0
    player_new_x=0
    player_new_y=0
    player_can_move=0

    # Хар-ки игрока
    declare -A player_stats
    player_stats["vision_radius"]=1
    player_stats["hp"]=20
    player_stats["max_hp"]=20
    player_stats["PV"]=0
    player_stats["DV"]=10
    player_stats["base_dmg"]="1 2 0 0"
    player_stats["base_accuracy"]=0

    player_stats["hp_regeneration_rate"]=30

    # Инвентарь

    declare -a inventory

    declare -A equipment

    declare -a categories_names
    categories_names[0]="One-hand Weapons"
    categories_names[1]="Shields"
    categories_names[2]="Helmets"
    categories_names[3]="Body Armors"
    categories_names[4]="Boots"
    categories_names[5]="Potions"
    categories_names[6]="Tools"

    declare -A categories_ids
    categories_ids["one_hand_weapon"]=0
    categories_ids["shield"]=1
    categories_ids["helmet"]=2
    categories_ids["body_armor"]=3
    categories_ids["boots"]=4
    categories_ids["potion"]=5
    categories_ids["tools"]=6

    declare -A letters_to_items
    declare -A letters_to_items_xx
    declare -A letters_to_items_yy

    # Названия действий с предметами
    declare -A item_actions_names
    item_actions_names["drop_item"]="Drop"
    item_actions_names["abort_choosing"]="Abort"
    item_actions_names["equip_item"]="Equip"
    item_actions_names["deequip_item"]="Deequip"
    item_actions_names["pick_up_item"]="Pick up"
    item_actions_names["smth"]="Something"
    item_actions_names["drink_potion"]="Drink"

    declare -A items_prototypes

    declare -a DL_items_tables

    # Предметы
    declare -A items

    new_item_generated='ttt'

    load_items_prototypes
    
    generate_item_from_proto knife
    equip_item_to_slot "first_hand" "$new_item_generated"
    generate_item_from_proto clothes
    equip_item_to_slot "chestplate" "$new_item_generated"
    generate_item_from_proto soul_lantern
    equip_item_to_slot "misc" "$new_item_generated"
    generate_item_from_proto healing_potion
    add_item_to_inventory "$new_item_generated"
    generate_item_from_proto healing_potion
    add_item_to_inventory "$new_item_generated"
    generate_item_from_proto healing_potion
    add_item_to_inventory "$new_item_generated"

    # Враги
    declare -A entities_prototypes
    declare -A entities_list
    declare -a DL_entities_tables
    entities_counter=0

    load_entities_prototypes

    # Глобалки для выбора цели
    targeting=0
    target_x=0
    target_y=0
    target_new_x=0
    target_new_y=0
    target_move=""
    target_execution=""

    # Начало игры
    cur_screen="main_menu"
    updated=0
    time_played=0
    last_time=$( date +%s )

    turn_counter=0

    log_message=""
    log_message_counter=1
#-----------------------------------------------------------------------



# Основной цикл
#-----------------------------------------------------------------------
    while true; do
        if [[ $cur_screen == "main_menu" ]]; then
            if [ $updated -eq 0 ]; then
                draw_main_menu
            else
                read -t0.01 -n1 input; 
                [[ $input != "" && ${translit[$input]} != "" ]] && input=${translit[$input]}
                case $input in
                    "z") start_new_game;;
                esac
            fi
        elif [[ $cur_screen == "the_dungeon" ]]; then
            if [ $updated -eq 0 ]; then
                just_do_nothing
            else
                update_time
                if [ $player_can_move -eq 1 ]; then
                    read -t0.01 -n1 input; 
                    [[ $input != "" && ${translit[$input]} != "" ]] && input=${translit[$input]}
                    case $input in
                        "w") ((player_new_y--)); update_player_position;;
                        "a") ((player_new_x--)); update_player_position;;
                        "s") ((player_new_y++)); update_player_position;;
                        "d") ((player_new_x++)); update_player_position;;
                        "r") reveal_map;;
                        ">") descend_downstairs;;
                        "<") ascend_upstairs;;
                        "l") look_at_something;;
                        "i") open_inventory_menu;;
                        ",") pick_up_items;;
                        " ") skip_turn;;
                    esac
                elif [ $targeting -eq 1 ]; then
                    read -t0.1 -n1 input; 
                    [[ $input != "" && ${translit[$input]} != "" ]] && input=${translit[$input]}
                    case $input in
                        "w") ((target_new_y--)); update_target_position;;
                        "a") ((target_new_x--)); update_target_position;;
                        "d") ((target_new_x++)); update_target_position;;
                        "s") ((target_new_y++)); update_target_position;;
                        "z") execute_target;;
                    esac
                fi
            fi
        elif [[ $cur_screen == "equipment_menu" || $cur_screen == "inventory_menu" || $cur_screen == "dropped_items_menu" ]]; then
            if [ $updated -eq 0 ]; then
                just_do_nothing
            else
                update_time
                read -t0.01 -n1 input; 
                [[ $input != "" && ${translit[$input]} != "" ]] && input=${translit[$input]}
                case $input in
                    "i") close_items_menu;;
                esac
            fi
        fi
    done

#-----------------------------------------------------------------------

bye