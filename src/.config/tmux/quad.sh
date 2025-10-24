#!/bin/sh
# 起点
tmux select-pane -t 0
tmux split-window -v
tmux split-window -h
tmux select-pane -t 0
tmux split-window -h
tmux select-pane -t 0
