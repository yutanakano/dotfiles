#!/bin/sh
# cmux layout: 左1枚 + 右4分割（合計5パネル）
#
# ┌──────────┬──────┬──────┐
# │          │  B   │  E   │
# │    A     ├──────┼──────┤
# │          │  C   │  D   │
# └──────────┴──────┴──────┘

# Aのペインを記録（後でフォーカスを戻すため）
FIRST_PANE=$(cmux list-panes | awk 'NR==1 {for(i=1;i<=NF;i++) if($i~/^pane:/) {print $i; exit}}')

# 左右に2分割 → BのsurfaceIDを出力から取得（例: "OK surface:29 workspace:9"）
B_SURFACE=$(cmux new-split right | awk '{print $2}')

# --surface でBを指定して上下分割 → CのsurfaceIDを取得
C_SURFACE=$(cmux new-split down --surface "$B_SURFACE" | awk '{print $2}')

# --surface でCを指定して左右分割 → D作成
cmux new-split right --surface "$C_SURFACE"

# --surface でBを指定して左右分割 → E作成
cmux new-split right --surface "$B_SURFACE"

# Aにフォーカスを戻す
cmux focus-pane "$FIRST_PANE"
