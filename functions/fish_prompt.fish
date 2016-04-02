# Set these options in your config.fish (if you want to :])
#
#     set -g theme_display_user yes
#     set -g theme_hostname never
#     set -g theme_hostname always
#     set -g default_user your_normal_user



# Backward compatibility
#
# Note: Do not depend on these behavior. These can be removed in anytime by the
# author in the name of code readability.
if set -q theme_hide_hostname
  # Existing $theme_hostname will always override $theme_hide_hostname
  if not set -q theme_hostname
    if [ "theme_hide_hostname" = "yes" ]
      set -g theme_hostname never
    end
    if [ "theme_hide_hostname" = "no" ]
      set -g theme_hostname always
    end
  end
end

function neka_segment -a bg fg text
  set separator \uE0B0
  if test -z "$segment_color"
      set segment_color normal
  end
  set -g segment (set_color $fg -b $bg)" $text"(set_color $bg -b $segment_color)"$separator$segment"
  set -g segment_color $bg
end

function neka_finish
  if test ! -z "$segment"
    printf "$segment "
    set segment
    set segment_color
  end
  set_color normal
end

function neka_user -d "Display current user if different from $default_user"
  set -l BG 444444
  set -l FG BCBCBC

  if [ "$theme_display_user" = "yes" ]
    if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
      set USER (whoami)
      get_hostname
      if [ $HOSTNAME_PROMPT ]
        set USER_PROMPT $USER@$HOSTNAME_PROMPT
      else
        set USER_PROMPT $USER
      end
      neka_segment $BG $FG $USER_PROMPT
    end
  else
    get_hostname
    if [ $HOSTNAME_PROMPT ]
      neka_segment $BG $FG $HOSTNAME_PROMPT
    end
  end
end

function get_hostname -d "Set current hostname to prompt variable $HOSTNAME_PROMPT if connected via SSH"
  set -g HOSTNAME_PROMPT ""
  if [ "$theme_hostname" = "always" -o \( "$theme_hostname" != "never" -a -n "$SSH_CLIENT" \) ]
    set -g HOSTNAME_PROMPT (hostname)
  end
end


function neka_dir -d "Display the current directory"
  neka_segment FFFFFF 000000 (prompt_pwd)" "
end

function neka_git -d "Display the current git state"
  set branch_symbol \uE0A0
  set BG AFD702
  set FG 005F01

  set -l stat (command git rev-list --left-right --count 'HEAD...@{upstream}' ^ /dev/null | awk '
    $1 > 0 { printf "↑"$1 }
    $1 > 0 && $2 > 0 { printf " " }
    $2 > 0 { printf "↓"$2 }
  ')" "

  if git_is_stashed
    set stat (command git stash list 2>/dev/null | wc -l | awk '$1 > 0 { print "⟀"$1 }')" $stat"
  end

  if git_is_staged
    if git_is_dirty
      set stat "± "
    else
      set stat "+ "
    end
  else if git_is_dirty
    set stat "● "
  end

  if git_is_touched
    set BG FFAF01
    set FG 664711
  end

  neka_segment $BG $FG "$branch_symbol "(git_branch_name)" $stat"
end

function neka_status -d "the symbols for a non zero exit status, root and background jobs"
  # if superuser (uid == 0)
  set -l uid (id -u $USER)
  if [ $uid -eq 0 ]
    neka_segment black FFAF01 "⚡"
  end

  # Jobs display
  if [ (jobs -l | wc -l) -gt 0 ]
    neka_segment black cyan "⚙"
  end
end

#
# Prompt
#
function fish_prompt
  git_is_repo; and neka_git
  neka_dir
  neka_user
  neka_status
  neka_finish
end
