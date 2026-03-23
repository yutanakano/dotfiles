#!/bin/sh
# cmux layout: 左1枚 + 右4分割（合計5パネル）
#
# ┌──────────┬──────┬──────┐
# │          │  B   │  C   │
# │    A     ├──────┼──────┤
# │          │  D   │  E   │
# └──────────┴──────┴──────┘

# Aのペインを記録（後でフォーカスを戻すため）
FIRST_PANE=$(cmux list-panes | awk 'NR==1 {for(i=1;i<=NF;i++) if($i~/^pane:/) {print $i; exit}}')

# 左右に2分割 → B
B_SURFACE=$(cmux new-split right | awk '{print $2}')

# Bを右に分割 → C
C_SURFACE=$(cmux new-split right --surface "$B_SURFACE" | awk '{print $2}')

# Bを下に分割 → D
cmux new-split down --surface "$B_SURFACE"

# Cを下に分割 → E
cmux new-split down --surface "$C_SURFACE"

# Aにフォーカスを戻す
cmux focus-pane "$FIRST_PANE"
