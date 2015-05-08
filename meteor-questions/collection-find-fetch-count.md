How would you write a query on the `Posts` collection that finds the number of posts with `kittens` in the `tags` attribute, using the `find` and `fetch` methods?

<button onclick="$('.hshow1').show()">Show Answer</button>

<div class="hshow1">
<code>
console.log(Posts.find({tags:"kittens"}).fetch().length)
</code>
</div>

How would you write a query on the `Posts` collection that finds the number of posts with `kittens` in the `tags` attribute, using the `find` and `count` methods?

<button onclick="$('.hshow2').show()">Show Answer</button>

<div class="hshow2">
<code>
console.log(Posts.find({tags:"kittens"}).count())
</code>
</div>

Which is better from an efficiency perspective, and why?

<button onclick="$('.hshow3').show()">Show Answer</button>

<div class="hshow3">
The version that uses count is more efficient, because it doesn't need to fetch the contents of all the matching documents.
</div>