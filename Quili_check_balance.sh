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

# 初始化24小时余额记录
BALANCE_24H_AGO=$PREVIOUS_BALANCE
START_TIME=$(date +%s)

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
        
        # 计算24小时的产量
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        if [ $ELAPSED_TIME -ge 86400 ]; then # 86400秒 = 24小时
            # 计算24小时内的产量
            PRODUCTION_24H=$(echo "$CURRENT_BALANCE - $BALANCE_24H_AGO" | bc)
            
            # 打印24小时产量
            echo "[$TIMESTAMP] 过去24小时产量: $PRODUCTION_24H QUIL" | tee -a $OUTPUT_FILE
            
            # 更新24小时余额记录和开始时间
            BALANCE_24H_AGO=$CURRENT_BALANCE
            START_TIME=$CURRENT_TIME
        fi
    else
        echo "[$TIMESTAMP] 提取余额失败，当前余额: $CURRENT_BALANCE" | tee -a $OUTPUT_FILE
    fi 
    
    # 等待1小时
    sleep 3600
done
