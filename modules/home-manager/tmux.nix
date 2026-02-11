{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    mouse = true;
    extraConfig = ''
      unbind-key -a -T root

      ##### Mouse support (needed after `unbind-key -a -T root`) #####

      # Колесо: если приложение “забрало” мышь — отдать ему, иначе скроллить историю tmux
      bind -n WheelUpPane   if -F "#{mouse_any_flag}" "send-keys -M" "copy-mode -e; send-keys -M"
      bind -n WheelDownPane if -F "#{mouse_any_flag}" "send-keys -M" "send-keys -M"

      # Клик ЛКМ по панели: фокус панели (и дать событие приложению, если надо)
      bind -n MouseDown1Pane select-pane -t= \; send-keys -M

      # Drag мышью: если приложение не забрало мышь — войти в copy-mode и начать выделение
      bind -n MouseDrag1Pane if -F "#{mouse_any_flag}" "send-keys -M" "copy-mode -M"

      # Отпустил ЛКМ после выделения -> копировать в системный буфер (Wayland wl-copy, иначе X11 xclip)
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "wl-copy || xclip -in -selection clipboard"

      set -g pane-border-lines "double"

      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on

      setw -g mode-keys emacs

      set -g mouse on

      set -s escape-time 0

      set -g history-limit 2000

      bind -n M-r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
      bind -n M-s choose-tree -s

      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      bind -n M-S-Left resize-pane -L 5
      bind -n M-S-Right resize-pane -R 5
      bind -n M-S-Up resize-pane -U 3
      bind -n M-S-Down resize-pane -D 3

      bind -n M-h split-window -v
      bind -n M-v split-window -h

      bind -n M-Enter new-window
      bind -n M-c kill-pane
      bind -n M-q kill-window
      bind -n M-d detach
      bind -n M-Q confirm-before -p "Kill entire session? (y/n)" kill-session

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy || xclip -in -selection clipboard"
      bind -n M-/ copy-mode \; command-prompt -p "(search down)" "send -X search-forward '%%%'"
      bind -n M-? copy-mode \; command-prompt -p "(search up)"   "send -X search-backward '%%%'"

      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'egel/tmux-gruvbox'
      set -g @plugin 'tmux-plugins/tmux-resurrect'
      set -g @plugin 'tmux-plugins/tmux-continuum'
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '15'
      run '~/.config/tmux/plugins/tpm/tpm'
    '';
  };

  home.packages = with pkgs; [
    wl-clipboard
    xclip
  ];
}
