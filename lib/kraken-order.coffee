_ = require 'lodash'
Properties = require './properties'

module.exports.activate = () ->
  atom.workspaceView.command('kraken:release', module.exports.order)

module.exports.order = () ->
  selection = atom.workspace.getActiveEditor().getSelection()
  selectedText = selection.getText()

  rules = getRules(selectedText)
  rules = assignWeights(rules)
  rules = sortRules(rules)
  result = combineRules(rules)

  selection.insertText result.replace /\n$/, ''

getRules = (selectedText) ->
  rules = []
  line = ''

  _.forEach selectedText.split('\n'), (rule) ->
    line = rule.split ':'
    rules.push
      'property': line[0],
      'value': line[1],
      'weight': 0
      'position': -1,
      'group': ''
      'groupIndex': 0

  return rules

assignWeights = (rules) ->
  properties = Properties()

  _.forEach rules, (rule) ->
    rule.weight = _.indexOf(properties, rule.property.trim()) + 1

    if (rule.weight == 0)
      rule.position = _.indexOf(rules, rule)

      # else
      #   rule.group = property.name
      #   rule.groupIndex = property.index

  return rules

sortRules = (rules) ->
  staticPos = _.remove rules, (rule) ->
    rule.position > -1

  sortedRules = _.sortBy rules, 'weight'

  _.forEach staticPos, (rule) ->
    sortedRules.splice(rule.position, 0, rule)

  return sortedRules

combineRules = (rules) ->
  selection = ''

  _.forEach rules, (rule) ->
    if (!rule.value)
      selection += rule.property + '\n'

    else if (!rule.property)
      # empty line

    else
      selection += rule.property + ':' + rule.value + ' //' + rule.group + '\n'

  return selection
