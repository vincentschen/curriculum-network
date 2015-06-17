# Meteor Templates

At its core, a social news site is composed of posts organized in lists, and that's exactly how we'll organize our templates.

Let's create a `/templates` directory inside /client. This will be where we put all our templates, and to keep things tidy we'll also create `/posts` inside `/templates` just for our post-related templates.

We're finally ready to create our second template. Inside `client/templates/posts`, create `posts_list.html`:

```html
<template name="postsList">
  <div class="posts">
    {{#each posts}}
      {{> postItem}}
    {{/each}}
  </div>
</template>
```

And `post_item.html`

```html
<template name="postItem">
  <div class="post">
    <div class="post-content">
      <h3><a href="{{url}}">{{title}}</a><span>{{domain}}</span></h3>
    </div>
  </div>
</template>
```

Note the `name="postsList"` attribute of the template element. This is the name that will be used by Meteor to keep track of what template goes where (note that the name of the actual file is not relevant).
