#!/bin/bash

base_dir=`pwd`

# Where should we save checkpoints and tensorboard events?
JOB_NAME=lamb_32k_chkpt150_seq512_16_2
OUTPUT_DIR=${base_dir}/bert_model_outputs

# Assumes job name in previous seq128 run, will resume training from epoch 150
CHECKPOINT_BASE_PATH=${OUTPUT_DIR}/saved_models/lamb_64k_seq128_64GPUs_1
CHECKPOINT_EPOCH150_NAME=`basename ${CHECKPOINT_BASE_PATH}/epoch150_*`
echo "checkpoint id: $CHECKPOINT_EPOCH150_NAME"

mkdir -p $OUTPUT_DIR

NCCL_TREE_THRESHOLD=0 deepspeed ${base_dir}/deepspeed_train.py \
--cf ${base_dir}/bert_large_lamb.json \
--max_seq_length 512 \
--output_dir $OUTPUT_DIR \
--print_steps 1 \
--job_name $JOB_NAME \
--deepspeed_config ${base_dir}/deepspeed_bsz16K_lamb_config_seq512.json \
--data_path_prefix /data/bert \
--rewarmup \
--load_training_checkpoint ${CHECKPOINT_BASE_PATH} \
--load_checkpoint_id ${CHECKPOINT_EPOCH150_NAME} \
&> 512_lamb_64GPU_80_2.log
