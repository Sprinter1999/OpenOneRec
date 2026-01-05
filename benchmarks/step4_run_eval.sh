# # Set environment variables
# export BENCHMARK_BASE_DIR="./benchmarks"
# export DATA_VERSION="v1.0"

# # Run evaluation script
# # bash eval_script.sh <model_path> <result_name> <enable_thinking>

# bash eval_script.sh /root/autodl-tmp/OneModel8B_Pro/models--OpenOneRec--OneRec-8B-pro/snapshots/f07787317272ce7df6ed3d187c471987965d3330 sft_think false

# Set environment variables
export BENCHMARK_BASE_DIR="./benchmarks"
export DATA_VERSION="v1.0"
# 新增：导出模型路径、结果名、是否启用thinking
export MODEL_PATH="/root/autodl-tmp/OneModel8B_Pro/models--OpenOneRec--OneRec-8B-pro/snapshots/f07787317272ce7df6ed3d187c471987965d3330"
export RESULT_NAME="sft_think_none"
export ENABLE_THINKING="false"

# Run evaluation script（不需要传位置参数了）
bash eval_script.sh
