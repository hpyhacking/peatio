# Peatio CI Documentation

# About
__Pipeline__ described in `config/pipelines/review.yml`

## Credentials overview

  - git_private_key - RSA key with access to your repository
  - github_token    - [Github token](https://github.com/settings/tokens) with access to web hooks
  - gcr_password    - JSON containing your [GCP credentials](https://developers.google.com/identity/protocols/application-default-credentials)
  - slack_webhook   - address of your [Slack Incoming Webhook](https://api.slack.com/incoming-webhooks)
  - kubeconfig      - your Kubernetes config encoded in base64

## Configurations overview

A pipeline is configured with __three sections__:

- `resource_types`
- `resources`
- `jobs`

In `resource_types` added additional resource types used by pipeline.
Each resource in a pipeline has a type. The resource's type determines what versions are detected, the bits that are fetched when used for a get step, and the side effect that occurs when used for a put step.
Out of the box, Concourse comes with a few resource types to cover common CI use cases like dealing with Git repositories and S3 buckets.
Here is `pull-request` type.

In `resources` described objects that are going to be used for jobs in the pipeline. They are listed under the resources key in the pipeline configuration.

In `jobs` described actions of pipeline, how resources progress through it, and how everything is visualized.

## Configure jobs

- `build-pull-request`
    - set `trigger: true` to make a new build of the job when new pull request available
    - configure `base: <branch_name>` to change which branch should be watched

- `build-master`
    - set `serial: true` to build and execute one-by-one, rather than executing in parallel
    - set `trigger: true` to make a new build of the job when new version available on git.
    - configure peatio-repository `uri` to change ssh link to your respository.
    - configure peatio-repository `branch` to change building branch of your respository.

# Getting stated

## Login to concourse
```shell
fly -t ci login -n TEAM_NAME -c CONCOURSE_URL
```

## Create or update the pipeline
```shell
fly -t ci set-pipeline -p peatio -c config/pipelines/review.yml -n
```

## Un-pause the pipeline
```shell
fly -t ci unpause-pipeline -p peatio
```
