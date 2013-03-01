#!/usr/bin/env node
prompt = require 'prompt'
pivotal =  require 'pivotal'
argv = require('optimist').argv
_ = require 'underscore'

promptSchema =
  properties:
    email:
      message: 'Email'
      required: true
    password:
      hidden: true

prompt.message = " "
prompt.delimiter = ""

activity = ['FfF']

latestDescription = ''

prompt.get promptSchema, (err, result)->
  pivotal.getToken result.email, result.password, (err, token) ->
    pivotal.useToken token.guid
    if argv.p
      getActivity argv.p
    else
      pivotal.getProjects (err, res)->
        console.log "Projects you belong to:"
        _.each res.project, (project)->
          console.log project.name + ": " + project.id

getActivity = (projectID) ->
  pivotal.getActivities {project: projectID}, (err, res)->
    latestFetchedDescription = res.activity[0].description
    if latestDescription != latestFetchedDescription
      latestDescription = latestFetchedDescription
      newActivity = _.map res.activity, (activity) -> activity.description
      diff = _.difference newActivity, activity
      _.each diff, (event)->
        console.log event
      activity = newActivity
    setTimeout ->
      getActivity (projectID)
    , 5000