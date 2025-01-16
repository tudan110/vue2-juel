<template>
  <!-- 单选的时候，value绑定id，多选的时候绑定展示名称字符串数组 -->
  <el-select :title="multiple ? optionData.label : ''" ref="select" :value="multiple ? optionData.label : value"
    placeholder="请选择" :size="size" clearable :filterable="filterable" :filter-method="filterMethod" :disabled="disabled"
    :multiple="multiple" :collapse-tags="collapseTags" @remove-tag="removeTag" @clear="clear"
    @visible-change="visibleChange" @focus="focus">
    <!-- 单选的时候，label绑定展示名称，多选的时候绑定空字符串 -->
    <el-option ref="option" class="tree-select__option" :value="optionData.id"
      :label="multiple ? '' : optionData.label">
      <el-tree ref="tree" class="tree-select__tree" :class="`tree-select__tree--${multiple ? 'checked' : 'radio'}`"
        :node-key="nodeKey" :data="data" :props="props" v-bind="treeAttr" :highlight-current="!multiple"
        :show-checkbox="multiple" :check-strictly="checkStrictly" :expand-on-click-node="multiple"
        :filter-node-method="filterNode" :default-expand-all="defaultExpandAll" @node-click="handleNodeClick"
        @current-change="handleCurrentChange" @check-change="handleCheckChange"></el-tree>
    </el-option>
  </el-select>
</template>

<script>
import _ from 'lodash'

export default {
  name: 'SelectTree',
  props: {
    size: {
      type: String,
      default: 'small'
    },
    // v-model绑定
    value: {
      type: [String, Number, Array],
      default: ''
    },
    // 树形的数据
    data: {
      type: Array,
      default: function () {
        return []
      }
    },
    // 每个树节点用来作为唯一标识的属性
    nodeKey: {
      type: [String, Number],
      default: 'id'
    },
    filterable: {
      type: Boolean,
      default: false
    },
    disabled: {
      type: Boolean,
      default: false
    },
    multiple: {
      type: Boolean,
      default: false
    },
    collapseTags: {
      type: Boolean,
      default: false
    },
    checkStrictly: {
      type: Boolean,
      default: false
    },
    defaultExpandAll: {
      type: Boolean,
      default: false
    },
    // tree的props配置
    props: {
      type: Object,
      default: function () {
        return {
          label: 'label',
          children: 'children'
        }
      }
    }
  },
  data() {
    return {
      optionData: {
        id: '',
        name: ''
      },
      filterFlag: false,
      checkedArray: []
    }
  },
  computed: {
    treeAttr() {
      if (this.value) {
        return {
          defaultExpandedKeys: [this.value]
        }
      } else {
        // 考虑 value 可能为 null
        return {}
      }
    }
  },
  watch: {
    value: {
      handler(val) {
        if (!this.isEmpty(this.data)) {
          this.init(val)
        } else {
          if (this.multiple) {
            const label = this.props.label || 'name'
            this.optionData[label] = null
          }
        }
      },
      immediate: true
    },
    data: function (val) {
      this.optionData = {
        id: '',
        name: ''
      }
      if (!this.isEmpty(val)) {
        this.init(this.value)
      }
    }
  },
  methods: {
    // 是否为空
    isEmpty(val) {
      return _.isEmpty(val)
    },
    handleNodeClick(data) {
      if (this.multiple) {
        return
      }
      if (data.disabled) {
        // 若节点 disabled === true，则取消选中
        this.$refs.tree.setCurrentKey(null)
        return
      }
      this.$emit('input', data[this.nodeKey])
      this.$emit('setLayer', data['layer'])
      this.$emit('selectNode', data[this.nodeKey])
      this.$refs.select.visible = false
    },
    handleCurrentChange(data) {
      if (this.multiple) {
        return
      }
      this.$emit('change', false)
    },
    handleCheckChange(data, checked, childrenChecked) {
      if (checked) {
        this.checkedArray.push(data)
      } else {
        let checkIndex = _.findIndex(this.checkedArray, data)
        this.checkedArray.splice(checkIndex, 1)
      }
      // 多选绑定的值是数组
      this.optionData.id = this.checkedArray
        .map(item => item[this.nodeKey])
      // 多选展示的 label 是字符串数组
      const label = this.props.label || 'name'
      this.optionData[label] = this.checkedArray
        .map(item => item[label])
      this.$emit('input', this.optionData.id)
      this.$emit('selectNode', this.optionData.id)
    },
    init(val) {
      // 多选
      if (this.multiple) {
        if (val) {
          const arr = val.toString().split(',')
          this.$nextTick(() => {
            this.$refs.tree.setCheckedKeys(arr)
            const nodes = this.$refs.tree.getCheckedNodes()
            this.optionData.id = val

            // 多选展示的 label 是字符串数组
            const label = this.props.label || 'name'
            this.optionData[label] = nodes
              .map(item => item[label])

          })
        } else {
          this.$refs.tree.setCheckedKeys([])
        }
      } else {
        // 单选
        val = val === '' ? null : val
        this.$nextTick(() => {
          this.$refs.tree.setCurrentKey(val)
          if (!val) {
            return
          }
          const label = this.props.label || 'name'
          const node = this.$refs.tree.getNode(val)
          this.optionData.id = val
          if (node) {
            this.optionData[label] = node.label
          }
        })
      }
    },
    removeTag(tag) {
      // this.handleCheckChange({ id: tag }, false)
    },
    visibleChange(e) {
      if (e) {
        const tree = this.$refs.tree
        this.filterFlag && tree.filter('')
        this.filterFlag = false
        let selectDom = null
        if (this.multiple) {
          selectDom = tree.$el.querySelector('.el-tree-node.is-checked')
        } else {
          selectDom = tree.$el.querySelector('.is-current')
        }
        setTimeout(() => {
          this.$refs.select.scrollToOption({ $el: selectDom })
        }, 0)
      }
      if (e) {
        this.$emit('visChange')
      }

    },
    focus(e) {
      this.$emit('focus')
    },
    clear() {
      this.$emit('input', null)
    },
    filterMethod(val) {
      this.filterFlag = true
      this.$refs.tree.filter(val)
    },
    filterNode(value, data) {
      if (!value) return true
      const label = this.props.label || 'name'
      return data[label].toUpperCase().includes(value.toUpperCase())
    }
  }
}
</script>

<style lang="scss" scoped>
.tree-select__option {
  height: auto;
  line-height: 1;
  padding: 0;
  background-color: #fff;

  &.el-select-dropdown__item {
    height: auto;
    line-height: 1;
    padding: 0;
    background-color: #fff;
  }

}

.tree-select__tree {
  padding: 4px 20px;
  font-weight: 400;

  &.tree-select__tree--radio {
    ::v-deep .el-tree-node.is-current>.el-tree-node__content {
      color: #409eff;
      font-weight: 700;
    }
  }

  /*::v-deep .el-tree-node.is-current > .el-tree-node__content {
    color: #409eff;
    font-weight: 700;
  }*/

  ::v-deep .el-tree-node:focus>.el-tree-node__content {
    background-color: #ffffff;
  }

}

/* 禁止通过 tag 取消选中 */
::v-deep .el-tag.el-tag--info .el-tag__close {
  display: none;
}
</style>
