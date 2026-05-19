[Read our cookie policy](https://northflank.com/legal/cookies)

[Guides](https://northflank.com/guides) [Changelog](https://northflank.com/changelog) [Blog](https://northflank.com/blog)

[← Back to Blog](https://northflank.com/blog)

![Header image for blog post: Best open source speech-to-text (STT) model in 2026 (with benchmarks)](https://assets.northflank.com/stt_3af98a0e9a.png?auto=avif&quality=100&width=937)

![Cristina Bunea](https://assets.northflank.com/TJG_6_THRH_9_U08627_C11_L2_051b9462de77_512_ed44f6c63d.png?auto=avif&width=100)

By [Cristina Bunea](https://northflank.com/author/cristina-bunea)

Published 6th January 2026

# Best open source speech-to-text (STT) model in 2026 (with benchmarks)

[AI](https://northflank.com/blog/tag/ai)

# Best open source speech-to-text (STT) model in 2026? (with benchmarks)

## **💡TL;DR**

The best open source speech-to-text (STT) models in 2026 are:

- **Canary Qwen 2.5B** for maximum English accuracy
- **IBM Granite Speech 3.3 8B** for enterprise-grade English ASR and translation
- **Whisper Large V3** for multilingual STT in 99+ languages
- **Whisper Large V3 Turbo or Distil-Whisper** when you need much faster throughput
- **Parakeet TDT** for ultra low-latency streaming
- **Moonshine** for edge and mobile devices

This guide compares WER accuracy, real-time factor (RTF), latency, languages, and deployment requirements, and shows how to run these models in production on [Northflank](https://northflank.com/product/gpu-paas).

Open source speech-to-text (STT) models now deliver accurate transcription that matches commercial services while offering deployment flexibility and cost advantages.

For engineers building voice applications, meeting transcription tools, or accessibility features, selecting the right STT model determines project viability.

This guide evaluates leading open source STT models based on benchmark performance, latency characteristics, and deployment requirements.

## How do you evaluate open source speech-to-text (STT) model performance?

For open source speech-to-text (STT) models, the most important performance metrics are word error rate (WER), real-time factor (RTF), end-to-end latency, supported languages, and model size / VRAM usage. In practice, WER and latency determine user experience, while model size and VRAM determine how you can deploy the model in production.

**Word Error Rate (WER)**: The primary accuracy metric. Lower percentages indicate better transcription accuracy. A 5% WER means the model makes 1 error per 20 words on average.

**Real-Time Factor (RTFx)**: Measures throughput as audio duration divided by processing time. RTFx of 100 processes 100 seconds of audio per second of compute time. Higher numbers indicate faster processing.

**Latency**: Time from audio input to transcription output. Critical for real-time applications like voice assistants or live captioning.

**Language support**: Number and quality of supported languages beyond English.

**Model size**: Parameter count affects memory requirements and inference speed. Smaller models enable edge deployment.

## Benchmark comparison of open source STT models

| Model | WER (%) | RTFx | Parameters | Languages | VRAM | License |
| --- | --- | --- | --- | --- | --- | --- |
| Canary Qwen 2.5B | 5.63 | 418 | 2.5B | English | depends on precision and batch size (no official figure) | CC-BY-4.0 |
| Granite Speech 3.3 8B | 5.85 | not publicly specified | ≈9B | English ASR, multi-lang AST | high (≈9B parameters, requires high-end GPU) | Apache 2.0 |
| Whisper Large V3 | 7.4 | varies by runtime; often an order of magnitude faster than real-time on modern GPUs | ≈1.55B | 99+ | ~10GB | MIT |
| Whisper Large V3 Turbo | 7.75 | 216 | 809M | 99+ | ~6GB | MIT |
| Distil-Whisper Large V3 | close to Whisper Large V3 | ~5–6× Whisper Large V3 (implementation-dependent) | 756M | English | ~5GB | MIT |
| Parakeet TDT 1.1B | ~8.0 | >2,000 (among the fastest models on Open ASR) | 1.1B | English | ~4GB | CC-BY-4.0 |

**Benchmark comparison of leading open source speech-to-text (STT) models (WER, RTF, parameters, languages, license)**

All WER and speed numbers in this guide are taken from public leaderboards and vendor benchmarks as of late 2026. These values change over time, so always check the latest model card or leaderboard snapshot for current results.

🔥 Deploy any AI/ML model on [Northflank](https://northflank.com/). Competitive on-demand GPU pricing.

## What are the best performing open source STT models?

### Canary Qwen 2.5B: Leading accuracy

![canary-qwen-2.5b.png](https://assets.northflank.com/canary_qwen_2_5b_cc4f10f647.png)

NVIDIA's Canary Qwen 2.5B currently tops the Hugging Face Open ASR Leaderboard with 5.63% WER. The model introduces a Speech-Augmented Language Model (SALM) architecture combining ASR with LLM capabilities.

The hybrid design pairs a FastConformer encoder optimized for speech recognition with an unmodified Qwen3-1.7B LLM decoder. This enables dual operation: pure transcription mode and intelligent analysis mode supporting summarization and question answering.

**Benchmark performance**:

- Word Error Rate: 5.63% (Open ASR Leaderboard average), 1.6% (LibriSpeech Clean), 3.1% (LibriSpeech Other)
- Real-Time Factor: 418x
- Training Data: 234,000 hours of English speech
- Parameter Count: 2.5 billion
- Noise Tolerance: 2.41% WER at 10 dB SNR

Training on diverse datasets including YouTube-Commons, YODAS2, LibriLight, and conversational audio provides robust performance across acoustic conditions. The model handles punctuation and capitalization automatically.

**Deployment notes**: Requires NVIDIA NeMo toolkit. Currently English-only. For audio longer than 10 seconds, use chunked inference with 10-second segments to prevent quality degradation.

### IBM Granite Speech 3.3 8B: Enterprise accuracy

IBM’s Granite Speech 3.3 8B is one of the top-ranked models on Hugging Face’s Open ASR leaderboard, with an average WER of about 5.85% across the benchmark suite.

The model achieves exceptional accuracy through a multi-stage training process: modality alignment of the Granite 3.3 8B Instruct model, followed by LoRA fine-tuning on diverse speech datasets. Training includes synthetic noise injection and random audio clipping to improve real-world robustness.

**Performance metrics**:

- Word Error Rate: 5.85% (Open ASR Leaderboard), 8.18% (Ionio clean speech benchmark)
- Real-Time Factor: – (not publicly specified)
- Languages: English, French, German, Spanish, with English-to-Japanese and English-to-Mandarin translation
- Parameter Count: ≈9B
- License: Apache 2.0

Independent benchmarks from Ionio show Granite achieving the lowest WER on clean audio while maintaining strong noise resilience with only 7.54% performance degradation from clean to noisy conditions.

### Whisper Large V3: Multilingual leader

OpenAI's Whisper Large V3 remains the gold standard for multilingual speech recognition. With 1.55 billion parameters and support for 99+ languages, the model handles diverse acoustic environments and rare vocabulary effectively.

**Key Features**:

- Language Support: 99+ languages with zero-shot capability
- Architecture: Transformer encoder-decoder with 32 decoder layers
- Training Data: 680,000 hours of multilingual web audio
- Mel-Spectrogram: 128 bins (increased from 80 in V2)
- Memory Requirements: ~10GB VRAM

The model performs automatic language identification, generates phrase-level timestamps, and handles punctuation/capitalization across supported languages. Multiple size variants (tiny through large) enable accuracy-speed trade-offs.

**Benchmark Results**: 7.4% WER average on mixed benchmarks. Performance varies by language based on training data distribution. Strongest on English, Spanish, French, German, and other high-resource languages.

### Whisper Large V3 Turbo: Optimized speed

Whisper Large V3 Turbo delivers 6x faster inference than Large V3 by reducing decoder layers from 32 to 4. Parameter count drops to 809 million while maintaining accuracy within 1-2% of the full model.

**Performance Characteristics**:

- WER: 7.75% on mixed benchmarks (comparable to Large V2)
- Inference Speed: 216x real-time factor on Groq infrastructure
- Parameter Count: 809 million
- Memory: ~6GB VRAM
- Languages: 99+ (same as Large V3)

The model was fine-tuned for two additional epochs on transcription data only. Translation performance declined because translation data was excluded from fine-tuning, but transcription quality matches Large V2 across most languages.

**When to use**: Applications prioritizing speed over maximum accuracy, especially for multilingual transcription where the 6x speedup justifies minor accuracy trade-offs.

## High-performance and efficient STT variants

### Distil-Whisper: Efficiency through distillation

Distil-Whisper achieves 6x faster inference than Whisper Large V3 while performing within 1% WER on out-of-distribution audio. Knowledge distillation creates a compact 756 million parameter model from Large V3's 1.54 billion.

**Technical approach**:

- Copies entire encoder from Whisper Large V3 (frozen during training)
- Uses only 2 decoder layers initialized from first and last layers of Whisper
- Trained on diverse pseudo-labeled dataset with WER filtering

**Performance benchmarks**:

- WER: Within 1% of Whisper Large V3 on short-form, within 1% on sequential long-form
- Benchmarks in the Distil-Whisper release show similar or slightly better performance than Whisper Large V3 on long-form, chunked audio, with fewer repeated phrases and lower insertion rates, while running several times faster.
- Speed: 6.3x faster than Large V3, 1.1x faster than Distil-Large-V2
- Noise Robustness: 1.3x fewer repeated 5-gram duplicates, 2.1% lower insertion error rate

**Limitation**: Currently English-only. For multilingual, use Whisper Turbo which applies similar optimization principles.

### Parakeet TDT: Ultra-fast processing

NVIDIA's Parakeet TDT models prioritize inference speed for real-time applications. The 1.1B parameter variant achieves RTFx near >2,000 (among the fastest models on Open ASR), as reported on the Hugging Face Open ASR leaderboard as of late 2026, processing audio dramatically faster than Whisper variants.

The RNN-Transducer architecture enables streaming recognition with minimal latency. Training on 65,000 hours of diverse English audio provides robust performance across conversational speech, audiobooks, and telephony.

**Speed vs accuracy trade-off**: Ranks 23rd in accuracy on Open ASR Leaderboard but processes audio 6.5x faster than Canary Qwen. CTC-based architecture optimizes for throughput over contextual understanding.

**Use cases**: Live captioning, real-time transcription, phone tree systems where speed determines user experience and minor accuracy trade-offs are acceptable.

## Foundation and alternative STT approaches

### Wav2Vec 2.0: Self-Supervised Learning

Meta's Wav2Vec 2.0 pioneered self-supervised speech recognition, demonstrating that models can achieve strong performance with minimal labeled data. The approach learns representations from unlabeled audio before fine-tuning on transcribed speech.

**Key Innovation**: Achieves 4.8/8.2 WER on LibriSpeech test sets using only 10 minutes of labeled data plus pretraining on 53,000 hours of unlabeled data. With full LibriSpeech training data, achieves 1.8/3.3 WER (clean/other).

**Architecture**: Encoder module processes raw audio into speech representations, fed to Transformer that captures sequence-level context. Contrastive learning during pretraining masks portions of speech representations and predicts them correctly.

**XLSR Variant**: Cross-lingual training on 53 languages enables representations shared across related languages. Achieves 72% relative phoneme error rate reduction on CommonVoice, 16% WER improvement on BABEL compared to monolingual training.

**Current Status**: Ionio benchmarks show 37.04% WER on clean speech and 54.69% WER on noisy speech, indicating Wav2Vec2 struggles in production environments compared to newer models. Best suited for research, fine-tuning on domain-specific tasks, or low-resource language development.

### Moonshine: Edge Deployment

Useful Sensors' Moonshine targets mobile and embedded deployment with models as small as 27 million parameters. Despite compact size, achieves competitive accuracy on resource-constrained devices.

The architecture enables offline transcription on smartphones, IoT devices, and edge hardware where cloud connectivity or privacy concerns preclude API usage. Moonshine variants outperform Whisper Tiny and Small despite significantly smaller model sizes.

**Deployment Scenarios**: On-device voice assistants, industrial equipment with offline requirements, privacy-sensitive applications, bandwidth-constrained environments.

## How do you deploy open source speech-to-text models on Northflank?

![CleanShot 2025-11-21 at 13.36.22@2x.png](https://assets.northflank.com/Clean_Shot_2025_11_21_at_13_36_22_2x_13dc910e87.png)

[Northflank](https://northflank.com/) provides production-ready, self-serve infrastructure for deploying open source STT models at scale with [GPUs](https://northflank.com/pricing), auto-scaling, and managed operations.

**Infrastructure benefits**:

- GPU instances (A100, H100, H200, B200) for accelerated inference
- Automatic scaling based on request volume and latency targets
- Container-based deployment with Docker and Kubernetes
- Environment management for model configurations and API keys
- Integrated monitoring, logging, and alerting
- Persistent storage for model weights and audio processing

**Deployment workflow**:

1. Package STT model in Docker container with dependencies
2. Configure GPU requirements based on model size
3. Set up auto-scaling policies for request patterns
4. Deploy to Northflank with managed infrastructure
5. Monitor performance and optimize resource allocation

For detailed deployment guidance, see our [guide on deploying open source text-to-speech models](https://northflank.com/blog/best-open-source-text-to-speech-models-and-how-to-run-them#how-to-run-anopen-source-texttospeech-model) which covers similar infrastructure patterns.

## Which open source STT model should you choose?

The best open source speech-to-text model for you depends on four constraints: language coverage, accuracy target, latency budget, and hardware limits. For English-only workloads with strict accuracy requirements, Canary Qwen 2.5B or IBM Granite Speech 3.3 8B are strong choices. For multilingual workloads, Whisper Large V3 or Whisper Large V3 Turbo are better. For low-latency streaming, Parakeet TDT or Distil-Whisper are more suitable. For edge devices, Moonshine provides the smallest footprint.

**For maximum accuracy (English)**:

- Primary: Canary Qwen 2.5B (5.63% WER)
- Alternative: IBM Granite Speech 3.3 8B (5.85% WER)

**For multilingual applications**:

- Best Quality: Whisper Large V3 (99+ languages)
- Best Speed: Whisper Large V3 Turbo (6x faster, 99+ languages)

**For speed-critical applications**:

- Real-Time: Parakeet TDT (2,728x RTFx)
- Balanced: Distil-Whisper (6x faster than Whisper, English-only)

**For resource-constrained deployment**:

- Edge/Mobile: Moonshine (27M parameters)
- Balanced: Distil-Whisper (756M parameters, low VRAM)

**For low-resource languages**:

- Foundation: Wav2Vec 2.0 XLSR (fine-tune on target language)
- Multilingual: Whisper models (strong zero-shot capability)

## Production considerations for STT systems

**Resource Planning**: Model size determines GPU requirements. Whisper Large V3 needs ~10GB VRAM, Turbo variants ~6GB, Canary Qwen ~8GB, Granite 8B requires substantial resources. Plan infrastructure accordingly.

**Batch vs Streaming**: Batch processing maximizes throughput for offline transcription. Streaming reduces latency for real-time applications but requires careful buffer management and affects accuracy.

**Audio preprocessing**: Models expect 16kHz mono audio. Implement resampling and stereo-to-mono conversion before inference. Poor audio quality compounds transcription errors.

**Error patterns**: Models occasionally hallucinate repeated phrases or produce incorrect homophones. Implement post-processing validation, especially for critical applications like medical or legal transcription.

**Latency optimization**: Use model quantization (int8, int4) to reduce memory and increase speed. FastWhisper implementation achieves 4x speedup with minimal accuracy loss through CTranslate2 optimization.

**Cost management**: Smaller models reduce compute costs but may require accuracy trade-offs. Evaluate error cost versus infrastructure expense for your specific use case.

## Open source speech-to-text vs commercial APIs

While open source models dominate accuracy leaderboards, commercial API services offer managed infrastructure, advanced features, and enterprise support.

### Leading Commercial Services

**Deepgram Nova-3**:Independent AA-WER benchmarks report Nova-3 around 18% WER on mixed real-world datasets, with sub-300 ms latency. Pricing is roughly $4.30 per 1,000 minutes for basic transcription as of mid-2026, but check Deepgram’s pricing page for current tiers.

**AssemblyAI Universal-2**: Highest accuracy among streaming commercial models at 14.5% WER. Supports 99+ languages with integrated speech intelligence (sentiment analysis, PII detection, speaker diarization). AssemblyAI’s Universal / Universal-2 models are priced on a per-hour basis, currently around $0.15/hour according to their pricing page, with earlier announcements citing $0.27/hour. Check AssemblyAI’s site for the latest rates.

**Google Cloud Chirp**: Best batch transcription accuracy at 11.6% WER. Supports 125+ languages with deep Google Cloud integration. Suitable for recorded content where streaming is not required.

**OpenAI GPT-4o-Transcribe**: 100+ language support with 320ms latency. Multimodal LLM approach handles complex audio conditions and code-switching effectively.

### Commercial vs open-source trade-offs

**Open source advantages**:

- Lower cost at scale (no per-minute fees)
- Complete data privacy (on-premises deployment or through Northflank’s [Bring Your Own Cloud](https://northflank.com/features/bring-your-own-cloud))
- Model customization and fine-tuning
- Canary Qwen 2.5B matches or beats many commercial APIs on independent leaderboards, although Google’s Chirp 2 still holds the top AA-WER score.

**When to choose commercial**: Rapid prototyping, low-volume applications, need for advanced features without custom development, regulated industries requiring vendor SLAs.

**When to choose open source**: High-volume applications, data privacy requirements, customization needs, cost optimization at scale, specific accuracy requirements met by latest models.

[**Start deploying open-source speech-to-text (STT) models on Northflank today**](https://app.northflank.com/signup)

Or [talk to an engineer](https://cal.com/team/northflank/northflank-intro?overlayCalendar=true) if you need help.

Share this article with your network

[X](https://x.com/intent/tweet?text=Northflank%20blog%20%E2%80%94%20Best%20open%20source%20speech-to-text%20(STT)%20model%20in%202026%20(with%20benchmarks)&url=https://northflank.com/blog/best-open-source-speech-to-text-stt-model-in-2026-benchmarks) [Share to Facebook](https://www.facebook.com/sharer/sharer.php?t=Northflank%20blog%20%E2%80%94%20Best%20open%20source%20speech-to-text%20(STT)%20model%20in%202026%20(with%20benchmarks)&u=https://northflank.com/blog/best-open-source-speech-to-text-stt-model-in-2026-benchmarks) [Share to LinkedIn](https://www.linkedin.com/shareArticle?mini=true&text=Northflank%20blog%20%E2%80%94%20Best%20open%20source%20speech-to-text%20(STT)%20model%20in%202026%20(with%20benchmarks)&url=https://northflank.com/blog/best-open-source-speech-to-text-stt-model-in-2026-benchmarks)

Related posts

[![](https://assets.northflank.com/How_to_deploy_vibe_coded_bolt_apps_to_production_1_d56bdccdb2.png?auto=avif&fit=crop&quality=90&width=820&height=461)](https://northflank.com/blog/how-to-deploy-vibe-coded-bolt-new-apps-to-production)

[![Daniel Adeboye](https://assets.northflank.com/DSC_2767_4_8736cb6b04.jpg?auto=avif&width=100)\\
\\
Daniel Adeboye • 19th May 2026\\
\\
**How to deploy vibe-coded Bolt.new apps to production in minutes** \\
\\
Deploy Bolt.new apps to production with Northflank using GitHub, HTTPS, CI/CD, automatic redeployments, environment variables, and scalable infrastructure in minutes.](https://northflank.com/blog/how-to-deploy-vibe-coded-bolt-new-apps-to-production)

[AI](https://northflank.com/blog/tag/ai)

[Case Study](https://northflank.com/blog/tag/case-study)

[![](https://assets.northflank.com/How_to_deploy_vibe_coded_Cursor_apps_to_production_6a0fd1e07a.png?auto=avif&fit=crop&quality=90&width=820&height=461)](https://northflank.com/blog/how-to-deploy-vibe-coded-cursor-apps-to-production)

[![Daniel Adeboye](https://assets.northflank.com/DSC_2767_4_8736cb6b04.jpg?auto=avif&width=100)\\
\\
Daniel Adeboye • 19th May 2026\\
\\
**How to deploy vibe-coded Cursor apps to production in minutes** \\
\\
Deploy Cursor apps to production with Northflank using Docker, GitHub, HTTPS, CI/CD, environment variables, and automatic redeployments in minutes.](https://northflank.com/blog/how-to-deploy-vibe-coded-cursor-apps-to-production)

[Apps](https://northflank.com/blog/tag/apps)

[AI](https://northflank.com/blog/tag/ai)

Also from the blog

- [5 best Bitbucket Pipelines alternatives for scalable CI/CD](https://northflank.com/blog/bitbucket-pipelines-alternatives)

- [What is PaaS hosting? Benefits and how it works](https://northflank.com/blog/what-is-paas-hosting)

- [Webapp.io alternatives for fast Docker builds and preview environments](https://northflank.com/blog/webapp-io-alternatives-for-fast-docker-builds-and-preview-environments)

- [How Yavendio scaled AI-powered WhatsApp commerce across LatAm with Northflank](https://northflank.com/blog/yavendio-scaled-ai-powered-whatsapp-commerce-across-latam-with-northflank)

- [7 best Upsun alternatives for flexible cloud deployment](https://northflank.com/blog/upsun-alternatives)