# Breeze-ASR-25-mlx

This model was converted to MLX format from [`MediaTek-Research/Breeze-ASR-25`](https://huggingface.co/MediaTek-Research/Breeze-ASR-25).

Breeze ASR 25 is an advanced ASR model fine-tuned from Whisper-large-v2, optimized for Taiwanese Mandarin and Mandarin-English code-switching scenarios.

## Key Features

- **Traditional Chinese direct output** (no OpenCC post-processing needed)
- **Mandarin-English code-switching**: 55.9% WER reduction vs Whisper-large-v2
- **Taiwanese Mandarin optimized**: CommonVoice16-zh-TW WER 7.97 (vs 9.84 baseline)
- **MLX native**: runs on Apple Silicon GPU via Metal

## Use with mlx-whisper

```bash
pip install mlx-whisper
```

```python
import mlx_whisper

result = mlx_whisper.transcribe(
    "audio.wav",
    path_or_hf_repo="Kenji8000/Breeze-ASR-25-mlx",
    language="zh",
)
print(result["text"])
```

## Performance

Tested on Mac Studio M2 Ultra 128GB, mlx-whisper 0.4.3, mlx 0.31.1:

| Metric | Value |
| --- | --- |
| RTF (Real-Time Factor) | 0.08x |
| Inference (model cached) | 0.52s for 6.3s audio |
| Memory (RSS) | ~3.1 GB |

## Conversion

Converted using [mlx-examples/whisper/convert.py](https://github.com/ml-explore/mlx-examples/tree/main/whisper) with dtype float16.

```bash
python convert.py --torch-name-or-path MediaTek-Research/Breeze-ASR-25 \
    --mlx-path mlx_models/breeze-asr-25 --dtype float16
# Note: rename output model.safetensors → weights.safetensors for mlx-whisper
```

## Original Model

- **Base**: openai/whisper-large-v2
- **Fine-tuned by**: [MediaTek Research](https://huggingface.co/MediaTek-Research)
- **License**: Apache 2.0
- **Paper**: [arXiv:2506.11130](https://arxiv.org/abs/2506.11130)

Downloads last month32

MLX

Hardware compatibility

[Log In](https://huggingface.co/login) to add your hardware

Quantized

MLX

3.08 GB

Inference Providers [NEW](https://huggingface.co/docs/inference-providers)

[Automatic Speech Recognition](https://huggingface.co/tasks/automatic-speech-recognition "Learn more about automatic-speech-recognition")

This model isn't deployed by any Inference Provider. [🙋Ask for provider support](https://huggingface.co/spaces/huggingface/InferenceSupport/discussions/new?title=Kenji8000/Breeze-ASR-25-mlx&description=React%20to%20this%20comment%20with%20an%20emoji%20to%20vote%20for%20%5BKenji8000%2FBreeze-ASR-25-mlx%5D(%2FKenji8000%2FBreeze-ASR-25-mlx)%20to%20be%20supported%20by%20Inference%20Providers.%0A%0A(optional)%20Which%20providers%20are%20you%20interested%20in%3F%20(Novita%2C%20Hyperbolic%2C%20Together%E2%80%A6)%0A)

## Model tree for Kenji8000/Breeze-ASR-25-mlx

Base model

[openai/whisper-large-v2](https://huggingface.co/openai/whisper-large-v2)

Finetuned

[MediaTek-Research/Breeze-ASR-25](https://huggingface.co/MediaTek-Research/Breeze-ASR-25)

Finetuned

( [17](https://huggingface.co/models?other=base_model:finetune:MediaTek-Research/Breeze-ASR-25))

this model

## Paper for Kenji8000/Breeze-ASR-25-mlx

[Paper • 2506.11130 •Published Jun 10, 2025• 5](https://huggingface.co/papers/2506.11130)