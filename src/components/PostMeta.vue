<template>
  <div class="post-meta">
    Posted {{ post.date }}.
    <div class="post-meta__warning" v-if="new Date().getTime() - new Date(post.date).getTime() > 365*24*60*60*1000">
      <span>❕本篇文章距离发表已大于一年，部分信息可能已失效</span>
    </div>
  </div>
</template>

<script>
export default {
  props: ["post"],
};
</script>

<style lang="scss">
.post-meta {
  font-size: 0.8em;
  opacity: 0.8;

  &__warning {
    font-size: 0.75em;
  }
}
</style>
