[user]
    name = ${name}
    email = ${email}
    editor = ${editor}
[alias]
    # Add
    ad = add

    # Commit
    cm = commit -m
    cc = commit --amend -m

    # Checkout
    co = checkout
    cb = checkout -b

    # Cherry-pick
    cp = cherry-pick

    # Diff
    df = diff

    # List
    tl = tag -l
    bl = branch -a
    rl = remote -v

    # Status
    st = status -s

    # Remote
    ra  = remote add
    rao = remote add origin
    rau = remote add upstream
    rs  = remote set-url
    rso = remote set-url origin
    rsu = remote set-url upstream

    # Logs
    l1 = log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all
    l  = log --pretty=oneline --decorate --abbrev-commit
    la = log --pretty=oneline --decorate --abbrev-commit --stat --all --walk-reflogs --relative --remotes
    lm = log --pretty=oneline --decorate --abbrev-commit --relative --merges --graph --remotes --tags
    ll = log --pretty=medium --decorate --abbrev-commit --graph --relative
    lla = log --pretty=medium --decorate --abbrev-commit --stat --all --walk-reflogs --relative --remotes
    lll = log --graph --pretty=format:'%Cred%h%Creset %an: %s %Creset%Cgreen(%cr)%Creset' --abbrev-commit --date=relative

    # remove file from changes list
    hide = update-index --assume-unchanged
    unhide = update-index --no-assume-unchanged

[color]
  diff = auto
  status = auto
[color "diff"]
    meta = yellow bold
    frag = magenta bold
    old = red bold
    new = green bold
[color "status"]
    added     = cyan bold
    branch    = cyan bold
    changed   = magenta bold
    deleted   = red bold
    untracked = yellow bold
[push]
    # 'git push' will push the current branch to its tracking branch
    # the usual default is to push all branches
    default = tracking
[core]
	  excludesfile = ~/.gitignore
    editor = ${editor}
[rebase]
    autostash = true
[merge]
    keepBackup = false
    tool = custom
[mergetool "custom"]
    keepTemporaries = false
    trustExitCode = false
    keepBackup = false
