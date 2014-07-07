Peatio Beijing
===

#### 在本地开发的`Git`流程

**clone project**

    git clone git@github.com:peatio/peatio.git
    cd peatio
    git remote add peatio_beijing git@github.com:peatio/peatio_beijing.git
    git fetch peatio_beijing
    git checkout -b peatio_beijing --trac peatio_beijing/master

**How to merge from master**

    # update to latest version of master
    git checkout master
    git pull

    # merge master to peatio_beiijng
    git checkout peatio_beijing
    git merge master

    # git push remote_name local_branch:remote_branch
    git push peatio_beijing peatio_beijing:master

**How to merge code back to master**

> NEVER

**Should I push peatio_beijing branch to master?**

> NEVER

***

#### 代码合并的原则

**从 `master` 到 `peatio_beijing` 的代码 merge 是单向的么？**
> 是的。

**如果从 `master` merge 过来的代码跟 `peatio_beijing` 冲突怎么办？**
> 永远在 `peatio_beijing` 解决代码冲突。

**如果需要一个功能，如何判断应该基于 `master` 上开发还是在 `peatio_beijing` 上开发？**
> 找团队商量。

**如果一个功能需要从 `peatio_beijing` merge 回去 `master` 怎么办？**
> 直接将代码复制到 `master`，并在 `master` 提交代码，然后在 merge 回 `peatio_beijing`，永远不反向 merge 回到 `master`。

**在什么地方管理 `master` 的计划任务?**
> 代码全部通过 github 的 pull-request 流程。任务管理可以直接用 Github 的 issues，并尽可能鼓励外部开发者参与到项目中来。不方便在 Github 上创建 issue 的话，可以在 Trello 上创建 card。

**在什么地方管理 `peatio_beijing` 的计划任务?**
> 代码全部通过 github 的 pull-request 流程。任务管理使用 Trello。

