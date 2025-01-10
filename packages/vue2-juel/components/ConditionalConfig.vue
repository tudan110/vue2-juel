<template>
  <div class="conditionConfig" :class="{'onlyCondition':onlyCondition}">
    <div v-if="!onlyCondition" class="display-line-bottom"></div>
    <div v-if="!onlyCondition" class="display-line-top"></div>

    <template v-for="(item,index) in condition">
      <!--条件节点-->
      <div :key="item.id" class="item" v-if="!['conditionGroup','connector'].includes(item.type)"
           :style="{width:conditionWidth - (item.level - maxLevel) * 52+'px'}">
        <div class="line"></div>

        <slot name="rowContent" v-bind:row="item"></slot>

        <div class="operation">
          <el-button type="text" size="small" icon="el-icon-plus"
                     @click="operationClick('addCondition',item,parentNode, condition, condition[index-1], condition[index+1],parentNodeBefore,parentNodeAfter)"></el-button>
          <el-button type="text" size="small" icon="el-icon-folder-add"
                     @click="operationClick('addConditionGroup',item,parentNode, condition, condition[index-1], condition[index+1],parentNodeBefore,parentNodeAfter)"></el-button>
          <el-button type="text" size="small" icon="el-icon-delete"
                     @click="operationClick('deleteNode',item,parentNode, condition, condition[index-1], condition[index+1],parentNodeBefore,parentNodeAfter)"></el-button>
        </div>
      </div>

      <!--连接符节点-->
      <div :key="item.id" class="item-lj" v-if="item.type === 'connector'">
        <div class="border">
          <el-radio-group value="AND" size="mini" v-model="item.connector">
            <el-radio-button label="AND">并</el-radio-button>
            <el-radio-button label="OR">或</el-radio-button>
          </el-radio-group>
        </div>
      </div>

      <!--分组节点-->
      <div :key="item.id" class="item item-group" v-if="item.type === 'conditionGroup'">
        <div class="subItem">
          <div class="line"></div>
          <condition-config :condition="item.children"
                            :parentNode="item"
                            :parentNodeBefore="condition[index-1]"
                            :parentNodeAfter="condition[index+1]"
                            :maxLevel="maxLevel"
                            @nodeClick="operationClick">
            <template v-for="slot in Object.keys($scopedSlots)" #[slot]="scope">
              <slot :name="slot" v-bind:row="scope.row"></slot>
            </template>
          </condition-config>
        </div>
      </div>
    </template>
  </div>
</template>

<script>
export default {
  name: 'conditionConfig',
  props: {
    condition: {
      type: Array,
      default: () => []
    },
    parentNode: {
      type: Object,
      default: () => ({})
    },
    parentNodeBefore: {
      type: Object,
      default: () => ({})
    },
    parentNodeAfter: {
      type: Object,
      default: () => ({})
    },
    maxLevel: {
      type: Number,
      default: () => 0
    },
    conditionWidth: {
      type: [Number, String],
      default: () => {
        return 500
      }
    }
  },
  data() {
    return {
      onlyCondition: (this.condition.length === 1 && this.condition[0].parentId === null) || this.condition.length === 0,
    }
  },
  mounted() {
    this.$nextTick(() => {
      this.resetLine()
    })
  },
  methods: {
    resetLine() {
      this.$nextTick(() => {
        let dom = document.querySelectorAll('.conditionConfig')
        dom.forEach(item => {
          let child = item.children
          let height = 0
          for (let i = child.length - 1; i >= 0; i--) {
            let ci = child[i]
            if (['item'].includes(child[child.length - 1].className) && ['display-line-bottom'].includes(ci.className)) {
              Object.assign(ci.style, {'height': 14 + 'px'})
              continue
            } else if (!ci.className.includes('display-line-bottom') && !ci.className.includes('display-line-top') && i !== child.length - 1) {
              height += ci.clientHeight
            }
          }
          if (['display-line-bottom'].includes(child[0].className)) {
            Object.assign(child[0].style, {'height': item.clientHeight - height - 16 + 'px'})
          }
        })
      })
    },

    operationClick(type, row, parentNode, condition, after, before, parentNodeBefore, parentNodeAfter) {
      this.$emit('nodeClick', type, row, parentNode, condition, after, before, parentNodeBefore, parentNodeAfter)
    }
  },
}
</script>

<style scoped lang="scss">
.conditionConfig {
  padding-left: 50px;
  border-left: 2px solid #CACACA;
  position: relative;
  width: auto;
  height: auto;

  .display-line-top {
    position: absolute;
    width: 4px;
    height: 14px;
    top: 0;
    left: -2px;
    background: white;
  }

  .display-line-bottom {
    position: absolute;
    width: 4px;
    height: 14px;
    bottom: 0;
    left: -2px;
    background: white;
  }

  .item {
    height: 30px;
    line-height: 28px;
    box-sizing: border-box;
    position: relative;
    padding-right: 4px;

    &:hover {
      background: #f2f2f2;
    }

    .line {
      position: absolute;
      top: 14px;
      left: -50px;
      width: 50px;
      height: 2px;
      background-color: #CACACA;
      z-index: 99;
    }

    .operation {
      height: 30px;
      text-align: right;
      float: right;

      ::v-deep.el-button {
        padding: 0;
        line-height: 30px;
        height: 30px;
        margin: 0;

        i {
          font-size: 22px;
          font-weight: 500;
        }
      }
    }
  }

  $borderWidth: 1px;
  $iljWidth: 60px;

  .item-lj {
    width: $iljWidth;
    height: 30px;
    box-sizing: border-box;
    margin: 0 0 0 -82px;
    background: #CACACA;
    border-radius: 4px;
    padding: $borderWidth;

    .border {
      width: calc($iljWidth - ($borderWidth * 2));
      height: calc(30px - ($borderWidth * 2));
      background: white;
      border-radius: 4px;
      padding: calc((30px - ($borderWidth * 2) - 22px) / 2) 0;
      box-sizing: border-box;
    }

    //border: 1px solid #CACACA;
    //border-radius: 4px;

    ::v-deep .el-radio-group {
      border-radius: 0;
      display: flex;
      flex-direction: row;
      justify-content: space-around;
      flex-wrap: nowrap;

      .el-radio-button {
        .el-radio-button__inner {
          padding: 5px 6px;
          font-size: 12px;
          box-sizing: border-box;
          border: none;
          border-radius: 0;
        }
      }
    }

    &::before {
      content: "";
      width: 0;
      height: 0;
    }
  }

  .item-group {
    background: none;
    height: auto;

    &:hover {
      background: none;
    }
  }

  .subItem {
    position: relative;

    .line {
      position: absolute;
      top: 14px;
      left: -50px;
      width: 50px;
      height: 2px;
      background-color: #CACACA;
      z-index: 99;
    }
  }
}

.onlyCondition {
  border: none;
  padding: 0;

  .item {
    .line {
      display: none;
    }
  }
}
</style>
