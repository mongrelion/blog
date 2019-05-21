+++
title = "Portable Pipelines"
date = "2019-03-21T00:00:00+00:00"
description = "Learn how to escape vendor lock-in with true portable pipelines"
tags = ["cicd", "devops", "bash"]
+++

---

# Portable Pipelines

Let's begin by making sure we are all on the same page:

One day a developer starts working on a project that will transform business
requirements into working features written in code.
This code will eventually be backed up in a source control management system. These
days git seems to be the contendant that won the race.
Once that code has been pushed (speaking in git terms here) all you should want to do
is to sit back and see that code be:
1. Built & Packaged
2. Unit Tested
3. Deployed to a staging environment
4. Tested against staging
5. Deployed to production
6. Tested with some sanity checks against production
7. Monitored

There is a specific reason why we want all this process to be automated: the more human
input required in a system the more that system is prone to errors.
Not to mention that humans are really slow with these sort of tasks compared to computers.

These tasks do not have to be difficult per sé. Let's take as an example a very simple Go
application and emulate how a team without CICD would go about it.  
First we need to assume the following:
   - There is a staging server under the host `my.staging.env.example.org`
   - There is a production server under the host `example.org`
   - We can log into those servers with a `deploy` user
   - There is a unit file loaded into systemd that knows how to run our Go app

1. Build:  
   This step spits out a binary under `dist/app`
   ```
   $ go build -o dist/app
   ```

2. Unit tests
   ```
   $ go test -v .
   ```

3. Deploy to a staging environment:
   ```
   $ scp ./dist/app:deploy@my.staging.env.example.org:/home/deploy/app
   $ ssh deploy@my.staging.env.example.org sudo systemctl restart app
   ```

4. Run some tests against staging:  
   Here we can be very pragmatic and run some smoke tests against staging using curl
   but the truth is that it probably won't cut it to test important user workflow, so
   a proper integration testing framework is necessary. We're going to go with [Godog](https://github.com/DATA-DOG/godog)
   for this one:
   ```
   $ godog
   ```

5. Deploy to production:
   ```
   $ scp ./dist/app:deploy@example.org:/home/deploy/app
   $ ssh deploy@example.org sudo systemctl restart app
   ```

6. Run some more tests against production:
   Again as with integration tests, curl might not be the best option here but for the pragmatism
   of this example we're just going to go for it:
   ```
   # test that TLS is not broken
   $ curl --head https://example.org
   # test that the login page still loads
   $ curl https://example.org/login
   # use your imagination
   ```
7. For monitoring you're on your own to chose whatever tool you prefer for this. In my example
   I have fancy Grafana dashboards connected to a Prometheus backend that pulls every 5 seconds
   metrics from the application itself. I won't show it so use your imagination.

# Choosing a CICD tool
Industry has settled for Jenkins as the standard CICD tool. It knows how to fetch your code from git
and it also knows how to run bash scripts. It's the best it can do. It also has a massive community
around it that has created a bunch of plugins for common tasks like compilation, packaging, testing,
notifications, deployments, etc.

The main issue with Jenkins is that it likes to be a snowflake: there is no way to automate the setting it
up for the first time. So if your Jenkins dies, there are manual steps required to set it up again (that
initialization token thing is what I'm talking about, for those familiar with it).
Also, the fact that there are so many plugins available is a double-edged sword, since the more plugins
you add to it, the slower and flakier the setup becomes (because of the risk of stale, abandoned or
malfunctioning plugins). This can eventually get on the way of upgrading your Jenkins version because
a plugin that is now an important part of your workflow won't work after upgrading Jenkins.
If there is *any* plugin at all that you should install on Jenkins though, apart from the standards (bash, git, etc.)
it should be [Jenkins Pipeline](https://jenkins.io/doc/book/pipeline/getting-started/), which will allow
you to define your pipeline as code, which is a good step towards creating portable pipelines.

Continuing with where we were left, which is choosing a CICD tool, anything that is able to clone your repo
and run your steps 1 through 7 should be enough.

In this post we're going to explore Jenkins, which is what we will begin with and then GitLabCI and TravisCI.

# Jenkins
Moving all the steps from 1 to 7 to a Jenkinsfile, it would basically look like this:

```
pipeline {
  agent any
  stages {
    stage('build') {
      steps {
        sh "go build -o dist/app"
      }
    }

    stage('test') {
      steps {
        sh "go test -v ."
      }
    }

    stage('deploy-staging') {
      steps {
        sh "scp ./dist/app:deploy@my.staging.env.example.org:/home/deploy/app"
        sh "ssh deploy@my.staging.env.example.org systemctl restart app"
      }
    }

    stage('test-staging') {
      steps {
        sh "godog"
      }
    }

    stage('deploy-production') {
      steps {
        sh "scp ./dist/app:deploy@example.org:/home/deploy/app"
        sh "ssh deploy@example.org systemctl restart app"
      }
    }

    stage('test-production') {
      steps {
        # test that TLS is not broken
        sh "curl --head https://example.org"
        # test that the login page still loads
        sh "curl https://example.org/login"
      }
    }

    stage('notify') {
      steps {
        sh "curl -X POST -d '{\"message\":\"deployment successful\"}' https://notifications.example.org"
      }
    }
  }
}
```

Then we will have to add this to our source repository, go to the Jenkins GUI, create our project, specify
that it is a Pipeline type of thing and do the rest of the things that the documentation says for
setting up a Jenkins Pipeline project.
Afterwards we should be able to commit changes to our code, push and see Jenkins take care of the rest.

Once of the problems with this approach, though, is that it will take a change in our project to test
an update in our Jenkinsfile (the change itself in the Jenkinsfile might suffice).  
Say, for example, that we made a mistake on the **deploy-production** stage. At that point we had
already promoted the artifact to staging but now we have to start over again because of our mistake. Maybe
it's a good way to punish ourselves and learn from our mistakes. But we there is no need to be so hard on
ourselves.

This is where we make our pipeline truly portable.

Instead of hardcoding all these steps into the `Jenkinsfile`, we are going to move all that into bash scripts.

It's a good practice to place those scripts under a `scripts` folder in the root of your project. Something
that will look more or less like this:

```
├── README.md
├── main.go
└── scripts
    ├── base.sh
    ├── build.sh
    ├── deploy.sh
    ├── notify.sh
    ├── smoke.sh
    └── test.sh

1 directory, 8 files
```

The name of the scripts should be descriptive enough at this point. The only one that I will mention
is that `base.sh` file. This one is where you would place variables and functions
that should be common to the rest of your scripts. For example, registry URLs,
deployment directories, deployment user, etc. should be exported from there
so that the rest of your scripts can reference it and you don't have to repeat yourself.

Afterwards, our Jenkinsfile should look now look like this:
```
pipeline {
  agent any
  stages {
    stage('build') {
      steps {
        sh "./scripts/build.sh"
      }
    }

    stage('test') {
      steps {
        sh "./scripts/test.sh unit"
      }
    }

    stage('deploy-staging') {
      steps {
        sh "./scripts/deploy.sh staging"
      }
    }

    stage('test-staging') {
      steps {
        sh "./scripts/test.sh staging"
      }
    }

    stage('deploy-production') {
      steps {
        sh "./scripts/deploy.sh production"
      }
    }

    stage('test-production') {
      steps {
        sh "./scripts/test.sh production"
      }
    }

    stage('notify') {
      steps {
        sh "./scripts/notify.sh"
      }
    }
  }
}
```

Some of the advantages of this approach are:
1. It's simple to read
2. You can test each script locally, so you don't have to commit and push your
   changes to see if your fix will actually work or not
3. Since you have a script for each task, now you have split your concerns/problems
   into smaller chunks, making traceability and debugging more easy.
4. Finally, you have achieved portability since the next time you have to move to
   a different CICD tool all you have to do is to invoke your scripts from the
   target configuration file for your pipeline, rather than figure out which
   plugin is compatible with the previous one that you're depending on

So, let's take a look at how we would have to do to migrate from Jenkins to GitLabCI:
# GitLabCI
All we have to do is to create a `.gitlab-ci.yml` file on the root of our project
and invoke our scripts from there:

```
build:
  script:
  - ./scripts/build.sh

test:
  script:
  - ./scripts/test.sh unit

deploy-staging:
  script:
  - ./scripts/deploy.sh staging

test-staging:
  script:
  - ./scripts/test.sh staging

deploy-production:
  script:
  - ./scripts/deploy.sh production

test-production:
  script:
  - ./scripts/test.sh production

notify:
  script:
  - ./scripts/notify.sh
```

# TravisCI
TravisCI is not much different. We define a `.travis.yml` on the root of our
project, create the project in the website, add the right hooks with GitHub and
we're good to go:

```
language: bash

script:
- ./scripts/build.sh
- ./scripts/test.sh unit
- ./scripts/deploy.sh staging
- ./scripts/test.sh staging
- ./scripts/deploy.sh production
- ./scripts/test.sh production
- ./scripts/notify.sh
```

# Final words
Bear in mind that the example exposed in this post is **very** simplistic, specially
around the deployment part of things. A mature deployment process involves some
authentication mechanism; the tests against staging and production might be more
or less rigorous, depending on the business priorities and what not.

Also, migrating CICD pipelines is not something that you do always but they do
tend to happen if the tool that was initially chosen for doing the job is not
cutting anymore for whatever reason your organization might have.

An extra point that I see with this approach is the possibility to test changes
of your pipeline without having to push changes in order to test them. This
increases testability and shortens dramatically the feedback loop.
