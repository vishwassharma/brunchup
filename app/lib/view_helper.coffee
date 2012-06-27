# Put your handlebars.js helpers here.
# Usage
# {{{replace resources.resume what="pagenumber" with="pagenumber" inContext="true"}}}
# use as replaceing string
# Provide it with a string if you have whatever to be replaced in context then give the key of that context
# else replace it with whatever is in hash with=" "
Handlebars.registerHelper 'replace', (context, options) ->
  hash = options.hash
  if hash['inContext'] is "true"
    tag = hash['with']
    result = context.replace '{{'+hash['what']+'}}',@[tag]
  else
    result = context.replace '{{'+hash['what']+'}}', hash['with']
  result
