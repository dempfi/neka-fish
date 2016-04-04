# Options
# set -g theme_display_user yes
# set -g theme_hostname never
# set -g theme_hostname always
# set -g default_user your_normal_user

function fish_prompt
  # Do not depend on these behavior.
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
  # ---


  # git
  # ---
  if git_is_repo
    set git_symbol \uE0A0
    set git_bg AFD702
    set git_fg 005F01

    set -l git_stat (command git rev-list --left-right --count 'HEAD...@{upstream}' ^ /dev/null | awk '
      $1 > 0 { printf "↑"$1 }
      $1 > 0 && $2 > 0 { printf " " }
      $2 > 0 { printf "↓"$2 }
    ')" "

    if git_is_stashed
      set git_stat (command git stash list 2>/dev/null | wc -l | awk '$1 > 0 { print "↙"$1 }')" $git_stat"
    end

    if git_is_staged
      if git_is_dirty
        set git_stat "± "
      else
        set git_stat "+ "
      end
    else if git_is_dirty
      set git_stat "● "
    end

    if git_is_touched
      set git_bg FFAF01
      set git_fg 664711
    end

    segment $git_fg $git_bg " $git_symbol "(git_branch_name)" $git_stat"
  end
  # ---


  # dir
  # ---
  segment 000000 FFFFFF " "(prompt_pwd)" "
  # ---


  # user
  # ---
  set user_bg 444444
  set user_fg BCBCBC
  set hostname ""
  if [ "$theme_hostname" = "always" -o \( "$theme_hostname" != "never" -a -n "$SSH_CLIENT" \) ]
    set hostname (hostname)
  end
  if [ "$theme_display_user" = "yes" ]
    if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
      set USER (whoami)
      if [ $hostname ]
        set USER_PROMPT $USER@$hostname
      else
        set USER_PROMPT $USER
      end
      segment $user_fg $user_bg " $USER_PROMPT "
    end
  else
    if [ $hostname ]
      segment $user_fg $user_bg " $hostname "
    end
  end
  # ---


  # status
  # ---
  # if superuser (uid == 0)
  set -l uid (id -u $USER)
  if [ $uid -eq 0 ]
    segment FFAF01 black "⚡"
  end
  # Jobs display
  if [ (jobs -l | wc -l) -gt 0 ]
    segment cyan black "⚙"
  end
  # ---

  segment_close
end
