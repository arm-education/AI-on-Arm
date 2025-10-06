from huggingface_hub import snapshot_download

   # Specify the target directory for downloading the model
target_directory = "models/hf_models/OpenELM-3B-Instruct"

   # Download a snapshot of the model repository
snapshot_download(
       repo_id="apple/OpenELM-3B-Instruct",
       local_dir=target_directory,
       revision="main",  # Optional: specify a branch, tag, or commit hash
       local_dir_use_symlinks=False  # Set to True if you want symlinks instead of file copies
   )
   # Download a snapshot of the tokenizer
snapshot_download(
        repo_id="meta-llama/Llama-2-7b-hf",
        local_dir="models/tokenizer/llama2",
        allow_patterns=["tokenizer.model", "tokenizer_config.json", "special_tokens_map.json"],
        local_dir_use_symlinks=False
    )