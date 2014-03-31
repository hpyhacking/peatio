An open-source crypto currency exchange
=====================================

### 在本地开发的`Git`流程

**clone codes**

    git clone git@github.com:peatio/peatio_beijing.git
    cd peatio_beijing
    git remote add peatio_opensource git@github.com:peatio/peatio.git

**How to merge from peatio_opensource**

    git fetch peatio_opensource
    git checkout -b local_branch
    git merge peatio_opensource/master
    git checkout master
    git merge local_branch

**How to merge code back to peatio_opensource**

> NEVER

### 代码合并的原则

* 从 `peatio_opensource` 到 `peatio_beijing` 的代码 merge 是单向的么？
> 是的

* 如果从 `peatio_opensource` merge 过来的代码跟 `opensource_beijing` 冲突怎么办？
> 永远在 `opensource_beijing` 解决代码冲突

* 如果需要一个功能，如何判断应该在 `peatio_opensource` 上开发还是在 `peatio_beijing` 上开发？
> 找团队商量

* 如果一个功能需要从 `opensource_beijing` merge back to `peatio_opensource` 怎么办？
> 直接将代码复制到 `peatio_opensource`，并在 `peatio_opensource` 提交代码，然后在   merge 回来，永远不直接 merge back 到 `peatio_opensource`

* 在什么地方管理 `peatio_opensource` 的计划任务?
> 代码全部通过 github 的 pull-request，review，然后 merge。任务管理直接用 Github 的 issues，并尽可能鼓励外部的人可以参与到项目开发中来。如果必要，可以在 Trello 上创建对应的 card

* 在什么地方管理 `peatio_beijing` 的计划任务?
> 代码全部通过 github 的 pull-request，review，然后 merge。任务管理使用 Trello。

