# Belle-whisper-large-v3-zh — MLX bfloat16

This is an MLX-format conversion of [BELLE-2/Belle-whisper-large-v3-zh](https://huggingface.co/BELLE-2/Belle-whisper-large-v3-zh) in
`bfloat16`, suitable for Apple Silicon inference via [mlx-audio](https://github.com/Blaizzy/mlx-audio) and
downstream tools like [oMLX](https://github.com/ml-explore/omlx).

## Conversion

Produced from the upstream PyTorch checkpoint with `mlx-audio` 0.4.3:

```bash
python -m mlx_audio.convert \
  --hf-path BELLE-2/Belle-whisper-large-v3-zh \
  --mlx-path ./Belle-whisper-large-v3-zh-mlx-bf16 \
  --dtype bfloat16 \
  --model-domain stt
```

The output directory contains the full HF processor surface
(`tokenizer.json`, `preprocessor_config.json`, `generation_config.json`,
etc.), unlike older legacy MLX Whisper conversions that only shipped
`config.json` \+ `weights.safetensors` and could not be loaded by
modern `WhisperProcessor`-based stacks. If you have a legacy directory
to upgrade in place, see [mlx-whisper-legacy-fixup](https://github.com/BRlin-o/mlx-whisper-legacy-fixup).

## Usage

### Via mlx-audio

```python
from mlx_audio.stt.generate import generate_transcription

result = generate_transcription(
    model="BRlin/Belle-whisper-large-v3-zh-mlx-bf16",
    audio="path/to/audio.wav",
    language="zh",
)
print(result.text)
```

### Via oMLX HTTP endpoint

```bash
curl -X POST http://127.0.0.1:8868/v1/audio/transcriptions \
  -H "Authorization: Bearer $OMLX_KEY" \
  -F "file=@path/to/audio.m4a" \
  -F "model=Belle-whisper-large-v3-zh-mlx-bf16" \
  -F "language=zh"
```

## Specs

| Field | Value |
| --- | --- |
| Architecture | Whisper large-v3 (fine-tuned) |
| Parameters | ~1.55 B |
| Precision | bfloat16 |
| n\_mels | 128 |
| Vocab size | 51866 |
| File size | ~2.9 GB |
| Sample rate | 16 kHz mono |
| Best for | Mandarin Chinese ASR (Simplified Chinese output) |

## License & Attribution

Inherits **Apache 2.0** from the upstream BELLE-2 model. All credit for
the underlying weights belongs to the BELLE-2 / LianjiaTech team and the
[Whisper-Finetune](https://github.com/shuaijiang/Whisper-Finetune) project — this repository only provides the MLX
format conversion for convenience on Apple Silicon.

If you use this model, please cite the upstream:

- BELLE: [https://github.com/LianjiaTech/BELLE](https://github.com/LianjiaTech/BELLE)
- Whisper-Finetune: [https://github.com/shuaijiang/Whisper-Finetune](https://github.com/shuaijiang/Whisper-Finetune)
- OpenAI Whisper: [https://github.com/openai/whisper](https://github.com/openai/whisper)

## Maintenance

This is a **one-shot conversion at 2026-04** and is not actively maintained
beyond bug fixes. If the upstream BELLE-2 model is updated, please re-run
the conversion command above, or open an issue.

Downloads last month127

Safetensors

Model size

2B params

Tensor type

F16

·

Files info

MLX

Hardware compatibility

[Log In](https://huggingface.co/login) to add your hardware

Quantized

MLX

3.08 GB

Inference Providers [NEW](https://huggingface.co/docs/inference-providers)

[Automatic Speech Recognition](https://huggingface.co/tasks/automatic-speech-recognition "Learn more about automatic-speech-recognition")

This model isn't deployed by any Inference Provider. [🙋Ask for provider support](https://huggingface.co/spaces/huggingface/InferenceSupport/discussions/new?title=BRlin/Belle-whisper-large-v3-zh-mlx-bf16&description=React%20to%20this%20comment%20with%20an%20emoji%20to%20vote%20for%20%5BBRlin%2FBelle-whisper-large-v3-zh-mlx-bf16%5D(%2FBRlin%2FBelle-whisper-large-v3-zh-mlx-bf16)%20to%20be%20supported%20by%20Inference%20Providers.%0A%0A(optional)%20Which%20providers%20are%20you%20interested%20in%3F%20(Novita%2C%20Hyperbolic%2C%20Together%E2%80%A6)%0A)

## Model tree for BRlin/Belle-whisper-large-v3-zh-mlx-bf16

Base model

[openai/whisper-large-v3](https://huggingface.co/openai/whisper-large-v3)

Finetuned

[BELLE-2/Belle-whisper-large-v3-zh](https://huggingface.co/BELLE-2/Belle-whisper-large-v3-zh)

Finetuned

( [7](https://huggingface.co/models?other=base_model:finetune:BELLE-2/Belle-whisper-large-v3-zh))

this model