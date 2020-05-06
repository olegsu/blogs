Open-Integration is a pipeline framework (aka pipeline-as-a-code), where you can create your pipeline, compile and execute it anywhere.  I created it because it helps me to automate some of my daily tasks to increase productivity.

Disclosure: I work @Codefresh, which is building a CI/CD platform with a strong orientation for a containerized application running in a Kubernetes environment. As Codefresh is adopting Golang, I wanted to learn and practice it. I, therefore, decided to write [open-integration](https://github.com/open-integration/core) using Golang. My state of mind is all about automating anything that does not require my intervention, both at work and in my personal life.

A couple of weeks ago, I was listening to a podcast (in Hebrew), where the guest in the show [described](https://barav.co/another-hour/) how he is saving an hour each day, consolidating all the tasks into one place and continuously prioritizing it.

TLDR: He is using [Trello](https://trello.com/) with 4 lists:

- Backlog - where he holds all the stuff that should be prioritized.
- Tomorrow - the plan for tomorrow.
- Today - the plan for today (prioritized).
- Done - what is done.

The guest in the show said that he is checking the email inboxes and other channels every few hours to add new tasks to the Trello board, updating the relevant board, prioritizing it (if needed) and focusing on the prioritized list, ignoring all the channels until the next sync. For me it sounds great, to consolidate all the tasks into one place, both for my personal life and my professional career, so I gave it a try.

I have made some changes that better worked for my workflow:

- I renamed the `Tomorrow` to `This week` list.
- I created labels with tags `Codefresh`, `Personal Life`, etc, to make sure I can group relevant cards.
- In the “Backlog” list, each card holds a checklist with the relevant tasks, each item will be converted into a single card when I move to “This Week” with the relevant labels.

Very quickly I noticed that there were too many cards in the `Done` list and I wanted to remove them, but also to keep that data for my next retrospective. I wanted to automate the following flow:

1. Update cards in Google spreadsheets
- add the card as a new row in case it is a new one
- update “update-at”, “labels”, “status” and other columns for cards that moved between lists
2. Archive all cards in the “Done” list to keep the board clean.

So I started to look for a solution that can archive them and also store them into my Google spreadsheet. This way I can come back to it in my next annual review to check exactly what was done in my professional life but also, to do some kind of personal retrospective.

There are many tools out there that I tried: [Zapier](https://zapier.com/), [IFTTT](https://ifttt.com/), [automate.io](https://automate.io/), [integromat](https://www.integromat.com/), [Microsoft flows](https://flow.microsoft.com/en-us/). Some of them worked pretty well, some didn’t match my requirements, some were a bit expensive. I decided that a good side project to work on would be an open-source pipeline execution engine that can do the simple tasks that I wanted to automate in my life for so long.

After this quick overview, which explained what was the motivation for me, and which tools I have checked, let’s dive into the Open-Integration project. The Open-Integration project is a pipeline framework, and it allows you to create pipeline-as-code. It is written in Golang. I took that approach of pipeline-as-code because of:

- We have way too many configuration files today (tons of yamls,tomls, and jsons are everywhere!)
- Test and debug! I was missing this ability everywhere, as a developer, I am trying to cover my code with tests, there is no reason for me to not do the same with my automated flows.

# Example

Lets create our first pipeline (requires go 1.11 and above):

[![asciicast](https://asciinema.org/a/312592.svg)](https://asciinema.org/a/312592)

- First let's install `oictl`, the command line tool that generates basic pipelines ( for mac you can use Homebrew, otherwise, download the binary from [Github](https://github.com/open-integration/oictl/releases) )
```bash
    brew tap open-integration/oictl
    brew install oictl
    mkdir hello-world && cd hello-world
    oictl generate pipeline
```
- Check the generated file
```golang
package main

import (
	"github.com/open-integration/core"
	"github.com/open-integration/core/pkg/state"
	"github.com/open-integration/core/pkg/task"
)

func main() {
	pipe := core.Pipeline{
		Metadata: core.PipelineMetadata{
			Name: "hello-world",
		},
		Spec: core.PipelineSpec{
			Services: []core.Service{
				core.Service{
					As:      "exec",
					Name:    "exec",
					Version: "0.0.1",
				},
			},
			Reactions: []core.EventReaction{
				core.EventReaction{
					Condition: core.ConditionEngineStarted(),
					Reaction: func(ev state.Event, state state.State) []task.Task {
						return []task.Task{
							buildTaskCommand0(),
						}
					},
				},
			},
		},
	}
	e := core.NewEngine(&core.EngineOptions{
		Pipeline: pipe,
	})
	core.HandleEngineError(e.Run())
}

func buildTaskCommand0() task.Task {
	return task.Task{
		Metadata: task.Metadata{
			Name: "hello-world-command-0-0",
		},
		Spec: task.Spec{
			Service:  "exec",
			Endpoint: "command",
			Arguments: []task.Argument{
				task.Argument{
					Key:   "command",
					Value: "echo \"hello-world\"",
				},
			},
		},
	}
}
```
- Now simply run:
```bash
    go run main.go
```
- See the output:
```bash
    cat logs/tasks/*
```
Let’s go over it:

Concepts:

- Engine (the `open-integration/core` pkg) - the piece to code that is executing the pipeline.
- Event - Indicator that something has changed in the state of the engine, allows us to react to it (`EventReaction` section).
- EventReation - A function that gets the current event and copy of the engine’s state, the function returns a set of tasks to be executed.
- Service - A standalone binary, the engine is communicating with it over gRPC, exposing endpoints to run some logical task.
- Task - execution of logical flow, a task is a request to call a service endpoint and pass the arguments.

# Architecture

![https://github.com/open-integration/core/raw/master/docs/architecture.png]

Flow:

![https://github.com/open-integration/core/raw/master/docs/flow-diagram.png](https://github.com/open-integration/core/raw/master/docs/flow-diagram.png)

# Use Cases

I have created a few pipelines which I use daily

1. [trello-google](https://github.com/olegsu/trello-sync): a pipeline that will read my Trello board, update a Google spreadsheet with new, updated, done tasks, and archive the “Done” list - this way I can review the spreadsheet once a while, to understand (using the labels I have put earlier) what has been accomplished, what is staying in the “Backlog” for too long and so on.
2. [jira-trello](https://github.com/olegsu/jira-sync): I really love task management tools, Jira is the one we are using at Codefresh, but I really do not want to sync every time I am mentioned in an issue or an issue I am watching has been updated. This pipeline is executed before I arrive to the office, I request Jira information using JQL (Jira query language), and create cards on my “Today” list with proper labels, so I can start my working day quickly to understand what is the picture, ignoring all the emails Jira is sending.
3. [open-integration/core CI](https://github.com/open-integration/core-ci-pipeline) - a pipeline that will use a Kubernetes service to run pods that are sharing a common PVC to clone, test, security scan, compile and release the `open-integration/core` repo.

# Contribution

Project plan: [Trello board](https://trello.com/b/BcAwtJXr/open-integration)

Open-Integration is an open-source tool, if you find it useful for you, please let me know. If you have any feedback, on the architecture, code, design, this blog post or any other stuff, I would love to talk to you! If you would like to contribute, please feel free to open a PR, the Open-Integration Github organization is made of the following repositories:

- [core](https://github.com/open-integration/core): the pipeline engine, exposing structs and functions to build the pipeline, services, task, etc.
- [oictl](https://github.com/open-integration/oictl): a command-line tool to generate code for pipeline and services
- [service-catalog](https://github.com/open-integration/service-catalog): All the available services