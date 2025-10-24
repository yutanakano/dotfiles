#!/bin/sh
# 起点
tmux select-pane -t 0
tmux split-window -v
tmux resize-pane -D 15
tmux select-pane -t 1
tmux split-window -h
tmux split-window -h
tmux select-pane -t 0
