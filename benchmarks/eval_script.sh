# #!/bin/bash

# # Set common variables
# MODEL_PATH=$1
# VERSION="${VERSION:-v1.0}"
# BASE_OUTPUT_DIR="${BENCHMARK_BASE_DIR}/results/${VERSION}/results_${2}"
# BASE_LOG_NAME="${BENCHMARK_BASE_DIR}/auto_eval_logs/${VERSION}/$2"
# ENABLE_THINKING=$3

#!/bin/bash

# 从环境变量读取参数，替代原来的位置参数
MODEL_PATH="${MODEL_PATH}"
RESULT_NAME="${RESULT_NAME}"
ENABLE_THINKING="${ENABLE_THINKING}"
VERSION="${VERSION:-v1.0}"

# 后续路径拼接逻辑也需要对应修改（把 $2 换成 $RESULT_NAME）
BASE_OUTPUT_DIR="${BENCHMARK_BASE_DIR}/results/${VERSION}/results_${RESULT_NAME}"
BASE_LOG_NAME="${BENCHMARK_BASE_DIR}/auto_eval_logs/${VERSION}/${RESULT_NAME}"

# 可选：增加环境变量为空的校验
if [ -z "$MODEL_PATH" ] || [ -z "$RESULT_NAME" ]; then
    echo "错误：MODEL_PATH 或 RESULT_NAME 环境变量未设置"
    exit 1
fi

# Read configuration from environment variables (set by eval_script.py)
# Fallback to hardcoded paths if not set
BENCHMARK_BASE_DIR="${BENCHMARK_BASE_DIR:-/home/user/benchmark}"
DATA_VERSION="${DATA_VERSION:-v1.0}"

BENCHMARK_DATA_DIR="${BENCHMARK_DATA_DIR:-${BENCHMARK_BASE_DIR}/data_${DATA_VERSION}}"
DATA_DIR="$BENCHMARK_DATA_DIR"

# Create output directory and log directory
mkdir -p "$(dirname "${BASE_LOG_NAME}")"
mkdir -p "$BASE_OUTPUT_DIR"

# Write debug info to log file
{
    echo "========== Task Configuration =========="
    echo "DATA_DIR: $DATA_DIR"
    echo "Enable Thinking: $ENABLE_THINKING"
    echo "========================================"
} >> "${BASE_LOG_NAME}.log"

# Build thinking arguments
THINKING_ARGS=""
if [ "$ENABLE_THINKING" = "true" ]; then
    THINKING_ARGS="--enable_thinking"
fi

echo "Thinking args: $THINKING_ARGS"

echo "Running all tasks"

# Task: rec_reason
python3 -u scripts/ray-vllm/evaluate.py \
    --task_types rec_reason \
    --gpu_memory_utilization 0.9 \
    --model_path "$MODEL_PATH" \
    --data_dir "$DATA_DIR" \
    --output_dir "${BASE_OUTPUT_DIR}" \
    --dtype bfloat16 \
    --worker_batch_size 5 \
    --overwrite \
    $THINKING_ARGS >> "${BASE_LOG_NAME}.log" 2>&1

# Task: item_understand
python3 -u scripts/ray-vllm/evaluate.py \
    --task_types item_understand \
    --gpu_memory_utilization 0.8 \
    --model_path "$MODEL_PATH" \
    --data_dir "$DATA_DIR" \
    --output_dir "${BASE_OUTPUT_DIR}" \
    --dtype bfloat16 \
    --worker_batch_size 250 \
    --overwrite \
    $THINKING_ARGS >> "${BASE_LOG_NAME}.log" 2>&1

# Task: ad
python3 -u scripts/ray-vllm/evaluate.py \
    --task_types ad \
    --gpu_memory_utilization 0.8 \
    --model_path "$MODEL_PATH" \
    --data_dir "$DATA_DIR" \
    --output_dir "${BASE_OUTPUT_DIR}" \
    --dtype bfloat16 \
    --worker_batch_size 1875 \
    --overwrite \
    --num_beams 32 --num_return_sequences 32 --num_return_thinking_sequences 1 \
    $THINKING_ARGS >> "${BASE_LOG_NAME}.log" 2>&1

# Task: product
python3 -u scripts/ray-vllm/evaluate.py \
    --task_types product \
    --gpu_memory_utilization 0.8 \
    --model_path "$MODEL_PATH" \
    --data_dir "$DATA_DIR" \
    --output_dir "${BASE_OUTPUT_DIR}" \
    --dtype bfloat16 \
    --worker_batch_size 1875 \
    --overwrite \
    --num_beams 32 --num_return_sequences 32 --num_return_thinking_sequences 1 \
    $THINKING_ARGS >> "${BASE_LOG_NAME}.log" 2>&1

# Task: label_cond
python3 -u scripts/ray-vllm/evaluate.py \
    --task_types label_cond \
    --gpu_memory_utilization 0.8 \
    --model_path "$MODEL_PATH" \
    --data_dir "$DATA_DIR" \
    --output_dir "${BASE_OUTPUT_DIR}" \
    --dtype bfloat16 \
    --worker_batch_size 1875 \
    --overwrite \
    --num_beams 32 --num_return_sequences 32 --num_return_thinking_sequences 1 \
    $THINKING_ARGS >> "${BASE_LOG_NAME}.log" 2>&1

# Task: video
python3 -u scripts/ray-vllm/evaluate.py \
    --task_types video \
    --gpu_memory_utilization 0.8 \
    --model_path "$MODEL_PATH" \
    --data_dir "$DATA_DIR" \
    --output_dir "${BASE_OUTPUT_DIR}" \
    --dtype bfloat16 \
    --worker_batch_size 1875 \
    --overwrite \
    --num_beams 32 --num_return_sequences 32 --num_return_thinking_sequences 1 \
    $THINKING_ARGS >> "${BASE_LOG_NAME}.log" 2>&1

# Task: interactive
python3 -u scripts/ray-vllm/evaluate.py \
    --task_types interactive \
    --gpu_memory_utilization 0.8 \
    --model_path "$MODEL_PATH" \
    --data_dir "$DATA_DIR" \
    --output_dir "${BASE_OUTPUT_DIR}" \
    --dtype bfloat16 \
    --worker_batch_size 250 \
    --overwrite \
    --num_beams 32 --num_return_sequences 32 --num_return_thinking_sequences 1 \
    $THINKING_ARGS >> "${BASE_LOG_NAME}.log" 2>&1

# Task: label_pred
python3 -u scripts/ray-vllm/evaluate.py \
    --task_types label_pred \
    --gpu_memory_utilization 0.8 \
    --model_path "$MODEL_PATH" \
    --data_dir "$DATA_DIR" \
    --output_dir "${BASE_OUTPUT_DIR}" \
    --dtype bfloat16 \
    --worker_batch_size 3200 \
    --max_logprobs 10000 \
    --overwrite \
    $THINKING_ARGS >> "${BASE_LOG_NAME}.log" 2>&1

echo "All tasks completed successfully"
