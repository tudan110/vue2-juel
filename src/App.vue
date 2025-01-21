<template>
  <div id="app">
    <Vue2Juel :expression="expression" :tree-options="treeOptions" @getExpression="getExpression" />
  </div>
</template>

<script>

export default {
  name: 'App',
  components: {},
  data() {
    return {
      // expression: '${ name == "张三" && (age >= 18 || sex == "男") && (score > 60 && (grade == "A" || level >= 3)) }',
      // expression: '${ (salary > 5000 && (department == "IT" || department == "HR")) || (experience >= 5 && (education == "Master" || education == "PhD")) }',
      // expression: '${ (status == "active" && (age >= 18 && age <= 65)) || (status == "inactive" && (lastLogin > "2023-01-01" || (loginCount > 100 && loginFrequency >= 5))) }',
      // expression: '${ (age > 18 && (name == "John" || name == "Alice")) && (status == "active" || (lastLogin > "2023-01-01" && loginCount > 100)) }',
      // expression: '${ age > 18 && name == "John" }',
      // expression: '${ (age > 18 && (name == "John" || name == "Alice")) || (status == "active" && score >= 80) }',
      // expression: '${ (salary > 5000 && department == "IT") || (experience >= 5 && education == "Master") }',
      // expression: '${ (status == "active" && (age >= 18 && age <= 65)) || (status == "inactive" && (lastLogin > "2023-01-01" || loginCount > 100)) }',
      // expression: '${ (status == "active" && (age >= 18 && (score > 60 || grade == "A"))) || (status == "inactive" && lastLogin > "2023-01-01") }',
      // expression: '${ ((salary > 5000 && department == "IT") || (experience >= 5 && education == "Master")) && (status == "active" || lastLogin > "2023-01-01") }',
      // expression: '${ (age > 18 && (name == "John" || name == "Alice")) && (status == "active" || (lastLogin > "2023-01-01" && loginCount > 100)) }',
      // expression: '${ (status == "active" && (age >= 18 && (score > 60 || grade == "A"))) || (status == "inactive" && (lastLogin > "2023-01-01" || loginCount > 100)) && department in ["IT", "HR"] }',
      // expression: "${ (age > 18 && (name == 'John' || name == 'Alice')) && (status == 'active' || (lastLogin > '2023-01-01' && loginCount > 100)) }",
      expression: "${ serviceTask_ae421a8c05224273a51454d7ddcb121e_abilityId_8cc652606dd44143b3d35808df7f3bc6.resultData.TotalNum == null || serviceTask_ae421a8c05224273a51454d7ddcb121e_abilityId_8cc652606dd44143b3d35808df7f3bc6.resultData.TotalNum == '' }",
      treeOptions: [
        {
          "id": "bodyIn",
          "label": "Body 入参",
          "disabled": true,
          "children":
            [
              {
                "id": "in.deviceIp",
                "label": "deviceIp"
              },
              {
                "id": "in.lranIpAddr",
                "label": "lranIpAddr"
              },
              {
                "id": "in.rranIpAddr",
                "label": "rranIpAddr"
              }
            ]
        },
        {
          "id": "serviceTask_ae421a8c05224273a51454d7ddcb121e_abilityId_8cc652606dd44143b3d35808df7f3bc6",
          "label": "测试环节",
          "disabled": true,
          "children":
            [
              {
                "id": "serviceTask_ae421a8c05224273a51454d7ddcb121e_abilityId_8cc652606dd44143b3d35808df7f3bc6.resultId",
                "label": "编码 (resultId)"
              },
              {
                "id": "serviceTask_ae421a8c05224273a51454d7ddcb121e_abilityId_8cc652606dd44143b3d35808df7f3bc6.resultDesc",
                "label": "描述 (resultDesc)"
              },
              {
                "id": "serviceTask_ae421a8c05224273a51454d7ddcb121e_abilityId_8cc652606dd44143b3d35808df7f3bc6.resultData",
                "label": "信息 (resultData)",
                "children":
                  [
                    {
                      "id": "serviceTask_ae421a8c05224273a51454d7ddcb121e_abilityId_8cc652606dd44143b3d35808df7f3bc6.resultData.TotalNum",
                      "label": "合计数量 (TotalNum)"
                    },
                    {
                      "id": "serviceTask_ae421a8c05224273a51454d7ddcb121e_abilityId_8cc652606dd44143b3d35808df7f3bc6.resultData.PublicNum",
                      "label": "公共数量 (PublicNum)"
                    },
                    {
                      "id": "serviceTask_ae421a8c05224273a51454d7ddcb121e_abilityId_8cc652606dd44143b3d35808df7f3bc6.resultData.PrivateNum",
                      "label": "私有数量 (PrivateNum)"
                    },
                    {
                      "id": "serviceTask_ae421a8c05224273a51454d7ddcb121e_abilityId_8cc652606dd44143b3d35808df7f3bc6.resultData.ClockState",
                      "label": "时钟状态 (ClockState)"
                    }
                  ]
              },
              {
                "id": "serviceTask_ae421a8c05224273a51454d7ddcb121e_abilityId_8cc652606dd44143b3d35808df7f3bc6.resultRaw",
                "label": "报文 (resultRaw)"
              }
            ]
        }
      ]
    }
  },
  methods: {
    getExpression(expression) {
      console.log(expression)
      this.$message.info(expression)
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
