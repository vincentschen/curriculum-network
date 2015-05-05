# Templates

Meteor's template language is called Spacebars.

To ease into Meteor development, we'll adopt an outside-in approach. In other words we'll build a "dumb" HTML/JavaScript outer shell first, and then hook it up to our app's inner workings later on.

This means that in this chapter we'll only concern ourselves with what's happening inside the `/client` directory.

If you haven't done so already, create a new file named main.html inside our /client directory, and fill it with the following code:

```html
<head>
  <title>Microscope</title>
</head>
<body>
  <div class="container">
    <header class="navbar navbar-default" role="navigation"> 
      <div class="navbar-header">
        <a class="navbar-brand" href="/">Microscope</a>
      </div>
    </header>
    <div id="main">
      {{> postsList}}
    </div>
  </div>
</body>
```

This will be our main app template. As you can see it's all HTML except for a single `{{> postsList}}` template inclusion tag, which is an insertion point for the upcoming postsList template. For now, let's create a couple more templates.