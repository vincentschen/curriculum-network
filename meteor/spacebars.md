# Spacebars

It's time to introduce Meteor's templating system, Spacebars. Spacebars is simply HTML, with the addition of three things: inclusions (also sometimes known as "partials"), expressions and block helpers.

Inclusions use the `{{> templateName}}` syntax, and simply tell Meteor to replace the inclusion with the template of the same name (in our case `postItem`).

Expressions such as `{{title}}` either call a property of the current object, or the return value of a template helper as defined in the current template's manager (more on this later).

Finally, block helpers are special tags that control the flow of the template, such as `{{#each}}…{{/each}}` or `{{#if}}…{{/if}}`.

## Going Further

You can refer to the [Spacebars documentation](https://github.com/meteor/meteor/blob/devel/packages/spacebars/README.md) if you'd like to learn more about Spacebars.