<template>
  <div class="condition-temp">

    <div class="condition-temp-con">
      <condition-config :key="comKey"
                        :condition="condition"
                        @nodeClick="nodeClick"
                        :maxLevel="maxLevel">
        <template slot="rowContent" slot-scope="{row}">
          <select-tree
            v-model="row.attribute"
            :data="treeOptions"
            size="mini"
            filterable
            clearable
          />

          <el-select style="width: 100px" size="mini" v-model="row.symbol" placeholder="请选择">
            <el-option label="==" value="=="></el-option>
            <el-option label="!=" value="!="></el-option>
            <el-option label=">" value=">"></el-option>
            <el-option label="<" value="<"></el-option>
            <el-option label=">=" value=">="></el-option>
            <el-option label="<=" value="<="></el-option>
            <!--<el-option label="IN" value="IN"></el-option>
            <el-option label="NOTIN" value="NOTIN"></el-option>
            <el-option label="LIKE" value="LIKE"></el-option>-->
          </el-select>

          <el-input style="width: 140px;" placeholder="请输入" size="mini" v-model="row.value"></el-input>
        </template>
      </condition-config>
    </div>

    <div>
      <el-button type="primary" plain size="mini" @click="getExpression()">确定</el-button>
    </div>

    <div v-if="showDebugButton" style="margin-top: 10px;">
      <el-button type="primary" plain size="mini" @click="getExpression()">生成表达式</el-button>
      <el-button type="primary" plain size="mini" @click="importJuelExpression()">导入表达式</el-button>
      <el-button type="primary" plain size="mini" @click="printCondition()">打印条件</el-button>
      <p>{{ debugExpression }}</p>
    </div>

  </div>
</template>

<script>
import ConditionConfig from './components/ConditionalConfig'
import SelectTree from './components/SelectTree'

export default {
  name: 'Vue2Juel',
  components: {ConditionConfig, SelectTree},
  props: {
    expression: {
      type: String,
      default: () => ''
    },
    showDebugButton: {
      type: Boolean,
      default: () => true
    },
    treeOptions: {
      type: Array,
      default: () => []
    }
  },
  mounted() {
    this.importJuelExpression(this.expression)
  },
  watch: {
    expression(newVal) {
      this.importJuelExpression(newVal)
    }
  },
  data() {
    return {
      comKey: 'abc',
      condition: [
        {id: 'xxx1', parentId: null, type: 'condition', level: 1, attribute: '', symbol: '', value: ''},
      ],
      /* condition: [
        {id: 'xxx1', parentId: null, type: 'condition', level: 1, attribute: 'name', symbol: '>', value: '1'},
        {id: 'xxx2', parentId: null, type: 'connector', level: 1, connector: 'AND'},  // 来自 &&
        {id: 'xxx3', parentId: null, type: 'condition', level: 1, attribute: 'age', symbol: '<', value: '2'},
        {id: 'xxx4', parentId: null, type: 'connector', level: 1, connector: 'OR'},   // 来自 ||
        {id: 'xxx5', parentId: null, type: 'condition', level: 1, attribute: 'sex', symbol: '==', value: 'male'},
        {id: 'xxx6', parentId: null, type: 'connector', level: 1, connector: 'AND'},  // 来自 &&
        {
          id: 'xxx7',
          parentId: null,
          type: 'conditionGroup',
          level: 1,
          children: [
            {id: 'xxx8', parentId: 'xxx7', type: 'condition', level: 2, attribute: 'age', symbol: '!=', value: '4'},
            {id: 'xxx9', parentId: 'xxx7', type: 'connector', level: 2, connector: 'OR'},  // 来自组内的 ||
            {id: 'xxx10', parentId: 'xxx7', type: 'condition', level: 2, attribute: 'sex', symbol: 'in', value: '5'}
          ]
        }
      ], */
      maxLevel: 3,

      debugExpression: '',
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
    }
  },
  methods: {
    /**
     * 生成 JUEL 表达式
     * @returns {string}
     */
    getExpression() {
      let expression = ''
      let loopCondition = (data, T) => {
        if (data && data.length > 0) {
          if (T === 'group') {
            expression += '( '
          }
          for (let i = 0; i < data.length; i++) {
            let item = data[i]
            if (item.type === 'condition') {
              expression += item.attribute + ' ' + item.symbol + ' ' + item.value + ' '
            }
            if (item.type === 'connector') {
              expression += (item.connector === 'AND' ? '&&' : '||') + ' '
              // expression += item.connector + ' '
            }
            if (item.type === 'conditionGroup') {
              loopCondition(item.children, 'group')
            }
          }
          if (T === 'group') {
            expression += ' ) '
          }
        }
      }
      loopCondition(this.condition)

      // JUEL 表达式
      expression = `$\{ ${expression}}`

      this.$emit('getExpression', expression)

      this.debugExpression = expression

    },
    printCondition() {
      console.log(this.condition)
    },
    /**
     * 如果一级目录删除完毕后 二级将自动层级上移
     */
    setLastGroup() {
      if (this.condition.length === 1 && this.condition[0].type === 'conditionGroup') {
        let data = JSON.parse(JSON.stringify(this.condition))
        this.condition = []
        data[0].children.forEach(item => {
          this.condition.push({...item, parentId: null, level: 1})
        })
      }

      this.setTreeLevel(this.condition)
    },
    //遍历设置树形层级
    setTreeLevel(nodes, level = 1) {
      nodes.forEach(node => {
        node.level = level // 设置当前节点的层级
        this.maxLevel = level
        if (node.children) {
          this.setTreeLevel(node.children, level + 1) // 递归设置子节点的层级
        }
      })
    },
    /**
     * @param type 操作类型
     * @param row 当前操作行
     * @param parentNode 当前操作行的父级
     * @param condition 当前操作行所处的list
     * @param before 当前操作行的上一行数据
     * @param after 当前操作行的下一行数据
     * @param parentNodeBefore 当前操作行 父类的上一行数据
     * @param parentNodeAfter 当前操作行 父类的下一行数据
     *
     * 如果有父级（parentNode 不为空）就证明当前行在分组中
     * 如果有上一行（before parentNodeBefore 不为空）证明当前行不是第一行
     * 如果有下一行（after parentNodeAfter 不为空）证明当前行不在最后一行
     */
    nodeClick(type, row, parentNode, condition, before, after, parentNodeBefore, parentNodeAfter) {
      this[type]({row, parentNode, condition, before, after, parentNodeBefore, parentNodeAfter})

      this.comKey = this.getOnlyId()
    },

    /**
     * @param tree 树形数据
     * @param nodeId 删除树形中指定id的数据
     */
    deleteAssignNode(tree, nodeId) {
      for (let i = 0; i < tree.length; i++) {
        if (tree[i].id === nodeId) {
          tree.splice(i, 1)
          return
        } else if (tree[i].children && tree[i].children.length > 0) {
          this.deleteAssignNode(tree[i].children, nodeId)
        }
      }
    },

    /**
     * 删除单行数据
     * @param arg
     */
    deleteNode(arg) {
      let {row, parentNode, condition, before, after, parentNodeBefore, parentNodeAfter} = arg
      //如果没有父级，证明当前行数据为一级目录
      if (Object.keys(parentNode).length === 0) {
        //如果当前行 前一行没有数据 那就需要删除当前行的下一行
        let connector = !!before ? before : !!after ? after : undefined
        //如果有before或者after就执行删除连接符，如果没有就直接删除操作行数据
        if (connector) this.deleteAssignNode(condition, connector.id)
        this.deleteAssignNode(condition, row.id)
      } else {
        //如果当前分组条件和连接符的总长度为3，证明条件有2个
        let nextChildren = []
        if (condition.length === 3) {
          condition.forEach(({type, children}) => {
            if (type === 'conditionGroup' && children && children.length > 0) {
              children.forEach(item => {
                nextChildren.push({...item, level: item.level - 1, parentId: parentNode.id})
              })
            }
          })
          if (nextChildren.length > 0) {
            parentNode.children = nextChildren
          } else {
            //如果当前行 前一行没有数据 那就需要删除当前行的下一行
            let connector = !!before ? before : !!after ? after : undefined
            //如果有before或者after就执行删除连接符，如果没有就直接删除操作行数据
            if (connector) this.deleteAssignNode(condition, connector.id)
            this.deleteAssignNode(condition, row.id)
          }
        } else if (condition.length === 1) {
          //如果当前行 前一行没有数据 那就需要删除当前行的下一行
          let connector = Object.keys(parentNodeBefore).length > 0 ? parentNodeBefore : Object.keys(parentNodeAfter).length > 0 ? parentNodeAfter : undefined
          //如果有before或者after就执行删除连接符，如果没有就直接删除操作行数据
          if (connector) this.deleteAssignNode(this.condition, connector.id)
          this.deleteAssignNode(this.condition, parentNode.id)
        } else {
          //如果当前行 前一行没有数据 那就需要删除当前行的下一行
          let connector = !!before ? before : !!after ? after : undefined
          //如果有before或者after就执行删除连接符，如果没有就直接删除操作行数据
          if (connector) this.deleteAssignNode(condition, connector.id)
          this.deleteAssignNode(condition, row.id)
        }
      }
      this.setLastGroup()
    },
    /**
     * 添加一行数据
     * @param arg
     */
    addCondition(arg) {
      let {row, condition, after} = arg
      let index = condition.map(i => i.id).indexOf(row.id)

      condition.splice(index + 2, 0, {
        id: this.getOnlyId(), parentId: row.parentId, type: 'condition', level: row.level,
        attribute: '', symbol: '', value: ''
      })
      if (after && Object.keys(after).length > 0) {
        condition.splice(index + 3, 0, {
          id: this.getOnlyId(), parentId: row.parentId, type: 'connector', level: row.level, connector: 'AND'
        })
      } else {
        condition.splice(index + 1, 0, {
          id: this.getOnlyId(), parentId: row.parentId, type: 'connector', level: row.level, connector: 'AND'
        })
      }

      this.setTreeLevel(this.condition)
    },
    /**
     * 添加一组数据数据
     * @param arg
     */
    addConditionGroup(arg) {
      let {row, condition, after} = arg
      let index = condition.map(i => i.id).indexOf(row.id)
      let pId = this.getOnlyId()
      let group = {
        id: pId, parentId: row.parentId, type: 'conditionGroup', level: row.level, children: [
          {
            id: this.getOnlyId(),
            parentId: pId,
            type: 'condition',
            level: row.level + 1,
            attribute: '',
            symbol: '',
            value: ''
          },
          {
            id: this.getOnlyId(),
            parentId: pId,
            type: 'connector',
            level: row.level + 1,
            connector: 'AND'
          },
          {
            id: this.getOnlyId(),
            parentId: pId,
            type: 'condition',
            level: row.level + 1,
            attribute: '',
            symbol: '',
            value: ''
          },
        ]
      }
      condition.splice(index + 2, 0, group)
      if (after && Object.keys(after).length > 0) {
        condition.splice(index + 3, 0, {
          id: this.getOnlyId(), parentId: row.parentId, type: 'connector', level: row.level, connector: 'AND'
        })
      } else {
        condition.splice(index + 1, 0, {
          id: this.getOnlyId(), parentId: row.parentId, type: 'connector', level: row.level, connector: 'AND'
        })
      }

      this.setTreeLevel(this.condition)
    },
    /**
     * 生成唯一id
     * len 机器码有多少位
     */
    getOnlyId(len = 13) {
      let date = (new Date()).valueOf()//获取时间戳
      let txt = '1234567890'//生成的随机机器码
      let pwd = ''//定义空变量用来接收机器码
      for (let i = 0; i < len; i++) {
        pwd += txt.charAt(Math.floor(Math.random() * txt.length))//循环机器码位数随机填充
      }
      return date + pwd//相加生成唯一ID
    },
    /**
     * 将JUEL表达式解析为condition数组
     */
    parseJuelToCondition(juelExpression) {
      // 移除 ${ 和 }
      let expression = juelExpression.trim().replace(/^\${\s*/, '').replace(/\s*}$/, '')
      this.condition = this.parseExpression(expression)
      this.comKey = this.getOnlyId() // 刷新组件
    },
    /**
     * 递归解析表达式
     */
    parseExpression(expr, level = 1, parentId = null) {
      const result = []
      let current = ''
      let depth = 0
      let lastChar = ''

      // 首先处理最外层的条件
      const outerMatch = expr.match(/^([^()]+?)(?=\s*&&\s*\(|\s*\|\|\s*\(|$)/)
      if (outerMatch) {
        const outerConditions = this.parseExpressionPart(outerMatch[1].trim(), level, parentId)
        result.push(...outerConditions)
        expr = expr.slice(outerMatch[0].length)
      }

      for (let i = 0; i < expr.length; i++) {
        const char = expr[i]

        if (char === '(') {
          depth++
          if (depth === 1) {
            // 检查连接符
            const connectorMatch = current.match(/\s*(&&|\|\|)\s*$/)
            if (connectorMatch) {
              result.push({
                id: this.getOnlyId(),
                parentId,
                type: 'connector',
                level,
                connector: connectorMatch[1] === '&&' ? 'AND' : 'OR'
              })
            }
            current = ''
            continue
          }
        } else if (char === ')') {
          depth--
          if (depth === 0) {
            const groupId = this.getOnlyId()
            const group = {
              id: groupId,
              parentId,
              type: 'conditionGroup',
              level,
              children: this.parseExpression(current, level + 1, groupId)
            }
            result.push(group)

            // 检查后续的连接符
            const rest = expr.slice(i + 1)
            const afterParen = rest.match(/^\s*(&&|\|\|)\s*/)
            if (afterParen) {
              result.push({
                id: this.getOnlyId(),
                parentId,
                type: 'connector',
                level,
                connector: afterParen[1] === '&&' ? 'AND' : 'OR'
              })
              i += afterParen[0].length
            }
            current = ''
            continue
          }
        }

        if (depth > 0) {
          current += char
        } else if (!/\s/.test(char) || lastChar === '\\') {
          current += char
        }
        lastChar = char
      }

      // 处理剩余内容
      if (current.trim()) {
        const conditions = this.parseExpressionPart(current.trim(), level, parentId)
        result.push(...conditions)
      }

      return result
    },
    /**
     * 解析单个条件
     */
    parseCondition(conditionStr, level, parentId) {
      try {
        const operatorRegex = /([a-zA-Z_][a-zA-Z0-9_.]*)\s*(>=|<=|==|!=|>|<|in)\s*(.+)/
        const match = conditionStr.trim().match(operatorRegex)

        if (!match) return null

        return {
          id: this.getOnlyId(),
          parentId,
          type: 'condition',
          level,
          attribute: match[1],
          symbol: match[2],
          value: match[3].trim()
        }
      } catch (error) {
        console.error('解析条件失败:', conditionStr, error)
        return null
      }
    },
    /**
     * 解析表达式片段
     */
    parseExpressionPart(part, level, parentId) {
      const result = []
      if (!part.trim()) return result

      try {
        const parts = part.split(/\s+(&&|\|\|)\s+/)

        for (let i = 0; i < parts.length; i++) {
          const trimmedPart = parts[i].trim()
          if (trimmedPart) {
            if (i % 2 === 0) {
              const condition = this.parseCondition(trimmedPart, level, parentId)
              if (condition) {
                result.push(condition)
              }
            } else {
              result.push({
                id: this.getOnlyId(),
                parentId,
                type: 'connector',
                level,
                connector: trimmedPart === '&&' ? 'AND' : 'OR'
              })
            }
          }
        }
      } catch (error) {
        console.error('解析表达式片段失败:', part, error)
      }

      return result
    },
    /**
     * 导入JUEL表达式
     */
    importJuelExpression(expression) {
      if (!expression) {
        // this.$message.warning('请输入JUEL表达式');
        return
      }
      try {
        this.parseJuelToCondition(expression)
        // this.$message.success('导入成功');
      } catch (error) {
        // this.$message.error('表达式格式错误');
        console.error('解析JUEL表达式错误:', error)
      }
    }
  }
}
</script>

<style scoped lang="scss">
.condition-temp {
  width: 100%;

  .condition-temp-con {
    width: 100%;
    height: 100%;
    overflow: auto;
    padding: 10px 20px 10px 40px;
    box-sizing: border-box;
  }
}
</style>
