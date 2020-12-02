<template>
  <g-link class="logo" to="/">
    <span class="logo__text"> &lArr; Back to Home </span>
  </g-link>
</template>

<style lang="scss">
.logo {
  text-decoration: none;
  color: var(--body-color) !important;
  background-color: var(--bg-color) !important;
  font-size: 0.9em;

  &__image {
    vertical-align: middle;
    border-radius: 99px;
    height: 40px;
    width: 40px;
    margin-right: 0.5em;
  }
}
</style>
