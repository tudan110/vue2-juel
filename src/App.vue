<template>
  <div id="app">
    <Vue2Juel @getExpression="getExpression" />
  </div>
</template>

<script>

export default {
  name: 'App',
  components: {},
  methods: {
    getExpression(expression) {
      console.log(expression)
      this.$message.info(expression);
    }
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
</style>
