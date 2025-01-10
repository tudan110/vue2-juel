// 引入组件
import Vue2Juel from './Vue2Juel.vue'

// 为组件提供 install 安装方法，供按需引入
Vue2Juel.install = (Vue) => {
    Vue.component(Vue2Juel.name, Vue2Juel)
}

// 导出组件
export default Vue2Juel
