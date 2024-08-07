#!/bin/bash

# 定义查询命令
COMMAND="./node-1.4.21.1-linux-amd64 --node-info"

# 定义输出文件
OUTPUT_FILE="balance_log.txt"

# 提取余额的函数
extract_balance() {
    # 从命令输出中提取余额
    BALANCE=$($COMMAND | grep "Unclaimed balance" | awk '{print $3}')
    echo $BALANCE
}

# 先执行一次查询并提取余额
PREVIOUS_BALANCE=$(extract_balance)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
echo "[$TIMESTAMP] 当前余额: $PREVIOUS_BALANCE QUIL" | tee -a $OUTPUT_FILE

# 无限循环，每小时查询一次
while true; do
    # 获取当前时间
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    
    # 提取余额
    CURRENT_BALANCE=$(extract_balance)
    
    # 确保余额为数值
    if [[ $CURRENT_BALANCE =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        # 计算每小时增加的余额
        INCREASE=$(echo "$CURRENT_BALANCE - $PREVIOUS_BALANCE" | bc)
        
        # 打印并保存结果
        echo "[$TIMESTAMP] 当前余额: $CURRENT_BALANCE QUIL, 每小时增加: $INCREASE QUIL" | tee -a $OUTPUT_FILE
        
        # 更新上一个余额
        PREVIOUS_BALANCE=$CURRENT_BALANCE
    else
        echo "[$TIMESTAMP] 提取余额失败，当前余额: $CURRENT_BALANCE" | tee -a $OUTPUT_FILE
    fi 
    # 等待1小时
    sleep 3600
done
