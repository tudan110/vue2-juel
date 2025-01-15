<template>
  <div id="app">
    <Vue2Juel
      :expression="expression"
      :tree-options="treeOptions"
      @getExpression="getExpression" />
  </div>
</template>

<script>

export default {
  name: 'App',
  components: {},
  data() {
    return {
      expression: "${ (age > 18 && (name == 'John' || name == 'Alice')) && (status == 'active' || (lastLogin > '2023-01-01' && loginCount > 100)) }",
      treeOptions: [
        {
          id: 'name',
          label: 'Tom',
          children: [
            {id: 'age', label: 'Age'},
            {id: 'status', label: 'Status'},
          ],
        },
        {
          id: 'login',
          label: 'Login',
          children: [
            {id: 'lastLogin', label: 'Last Login'},
            {id: 'loginCount', label: 'Login Count'},
          ],
        },
      ]
    }
  },
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
