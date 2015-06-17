How would you write a Spacebars template that shows `It's True` if `something` is `true`, and `It's False` otherwise?

<button onclick="$('.hshow').show()">Show Answer</button>

<div class="hshow">
<code>
{{#if something}}
  <p>It's true</p>
{{else}}
  <p>It's false</p>
{{/if}}
</code>
</div>