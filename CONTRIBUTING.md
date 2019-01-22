# Contributing to the Peatio

## Please read the following before reporting an issue. Let's respect each other...

### If your problem is with...

 - [Microkube](https://github.com/rubykube/microkube)
 - [Barong](https://github.com/rubykube/barong)
 - Cryptonode e.g [Bitcoind](https://github.com/bitcoin/bitcoin), [Geth](https://github.com/ethereum/go-ethereum),
    [Rippled](https://github.com/ripple/rippled), [BitGo](https://www.bitgo.com/)
 - [Workbench](https://github.com/rubykube/workbench) (DEPRECATED since 2.0)
 - [AppLogic](https://github.com/rubykube/applogic) (NOT SUPPORTED since 2.0)
 - [Peatio Trading UI](https://github.com/rubykube/peatio-trading-ui) (NOT SUPPORTED since 1.9)

Then please do not report your issue here - you should instead report it to appropriate repository or organisation.

### For local installation please use...

 - [Microkube](https://github.com/rubykube/microkube)
 - [Minimalistic local development environment with docker-compose](README.md) (ADVANCED)
 - [Workbench](https://github.com/rubykube/workbench) (DEPRECATED since 2.0)

Then please open an issue here **ONLY** if you use [Minimalistic local development environment with docker-compose](README.md):

### If your issue is...
  
  - New feature request but it is possible to add this feature in separate service using Event or Management API.
  - Described in [FAQ section](https://github.com/rubykube/peatio/issues?q=is%3Aissue+is%3Aclosed+label%3AFAQ) (we are working on it now)
  
Then please don't open new issue here.

### For enterprise support...

  - You can contact us on [peatio.tech](https://www.peatio.tech) or [discuss](https://discuss.rubykube.io)
  - Contact us by email: [hello@peatio.tech](mailto:hello@peatio.tech)

## Reporting an issue properly

By following these simple rules you will get better and faster feedback on your issue.

 - Search the closed issues for an already reported problem

### If you found an issue that describes your problem:

 - Please read other user comments first, and confirm this is the same issue: a given error condition might be indicative of different problems - you may also find a workaround in the comments.
 - Please add "same thing here" or "+1" comments so we will pay more attention to this issue.
 - You don't need to comment on an issue to get notified of updates: just hit the "subscribe" button.
 - Comment if you have some new, technical and relevant information to add to the case.
 - __DO NOT__ comment on closed issues or merged PRs. If you think you have a related problem, open up a new issue and reference the PR or issue.

### If you have not found an existing issue that describes your problem:

 1. Create a new issue, with a succinct title that describes your issue:
   - bad title: "API IS BROKEN!!!"
   - good title: "Don't expose null trade side on API v2"
 2. Reference Peatio version you are using:
 3. Reproduce your problem and get your logs showing the error.
 4. Provide any relevant detail about your specific configuration (e.g. application.yml, currencies.yml ...)

## Contributing a patch for a known bug, or a small correction

You should follow the basic GitHub workflow:

 1. Fork
 2. Commit a change with clear commit message.
 3. Make sure the tests pass and CI is not broken
 4. PR

 - Clearly point to the issue(s) you want to fix in your PR comment (e.g., `closes #1234`).
 - Prefer multiple (smaller) PRs addressing individual issues over a big one trying to address multiple issues at once.

## Contributing new features

You are heavily encouraged to first discuss what you want to do.
So start by opening an issue that clearly describes the use case you want to fulfill, or the problem you are trying to solve.

If this is a major new feature, you should then submit a proposal that describes your technical solution and reasoning.
If you had discussed it first, and got an approval (if there is a version(s) label on your issue) this will likely be greenlighted.
It's advisable to address all feedback on this proposal before starting actual work.

Then you should submit your implementation, clearly linking to the issue (and possible proposal).

Your PR will be reviewed by the project maintainers and community, before being merged.

It's mandatory to cover your code with tests!

## Coding Style

We hope to introduce this section soon.
