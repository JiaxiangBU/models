#!/bin/bash

export FLAGS_sync_nccl_allreduce=0
export FLAGS_eager_delete_tensor_gb=1.0

export CUDA_VISIBLE_DEVICES=0

pretrain_model_path="data/saved_models/matching_pretrained"
if [ ! -d ${pretrain_model_path} ]
then
     mkdir ${pretrain_model_path}
fi

python -u main.py \
      --do_train=true \
      --use_cuda=true \
      --loss_type="CLS" \
      --max_seq_len=50 \
      --save_model_path="data/saved_models/matching_pretrained" \
      --save_param="params" \
      --training_file="data/input/data/unlabel_data/train.ids" \
      --epoch=20 \
      --print_step=1 \
      --save_step=400 \
      --batch_size=256 \
      --hidden_size=256 \
      --emb_size=256 \
      --vocab_size=484016 \
      --learning_rate=0.001 \
      --sample_pro=0.1 \
      --enable_ce="store_true" | python _ce.py


save_model_path="data/saved_models/human_finetuned"
if [ ! -d ${save_model_path} ]
then
    mkdir ${save_model_path}
fi

python -u main.py \
      --do_train=true \
      --use_cuda=true \
      --loss_type="L2" \
      --max_seq_len=50 \
      --init_from_pretrain_model="data/saved_models/matching_pretrained" \
      --save_model_path="data/saved_models/human_finetuned" \
      --save_param="params" \
      --training_file="data/input/data/label_data/human/train.ids" \
      --epoch=50 \
      --print_step=1 \
      --save_step=400 \
      --batch_size=256 \
      --hidden_size=256 \
      --emb_size=256 \
      --vocab_size=484016 \
      --learning_rate=0.001 \
      --sample_pro=0.1 \
      --enable_ce="store_true" | python _ce.py
