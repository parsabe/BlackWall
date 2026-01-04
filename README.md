# BlackWall
A Safety Line Against Rogue AI 


<p align="center">
    <img src="assets/logo.png">
</p>



## Abstract
The increasing integration of social media and conversational AI into daily life has intensified concerns around the spread of harmful, illegal, and psychologically sensitive content, including suicidal ideation, self-harm, depression, and other forms of negative influence. Recent cases of emotional attachment to chatbots and instances where AI systems have unintentionally misled users on mental health issues highlight the urgency of reliable safety mechanisms. This paper presents Blackwall, a domain-aware and interpretable framework designed to identify, assess, and rank high-risk content across online platforms. By operating across heterogeneous data sources and providing transparent risk explanations, Blackwall supports early intervention, responsible moderation, and safer human–AI interaction. The framework aims to contribute toward ethically grounded content safety systems that can mitigate psychological harm while preserving transparency and trust.



<section id="introduction">


  <p>
    The <strong>Blackwall</strong> project focuses on developing a reliable and interpretable artificial
    intelligence system for identifying and assessing
    <strong>suicidal ideation alongside other harmful, illegal, and psychologically sensitive content</strong>,
    including self-harm, depression, and broader forms of negative or misleading influence.
    Rather than operating on social media platforms directly, Blackwall is trained and evaluated on curated
    datasets originating from online environments, with the primary objective of preventing intelligent systems
    from generating, reinforcing, or amplifying dangerous content.
  </p>
  <p>
    The system is designed not only to distinguish between low-risk and high-risk content, but also to provide
    transparent and explainable risk assessments that can support mental health professionals, safety moderators,
    and the development of responsible AI-driven tools.
  </p>

  <p>
    Blackwall is evaluated using a Twitter-derived dataset consisting of short text samples labeled as
    <em>“Not Suicide Post”</em> or <em>“Potential Suicide Post”</em>, and a Reddit SuicideWatch–derived dataset
    containing longer-form texts annotated with a severity score ranging from 0 to 5, reflecting increasing
    levels of suicide risk.
  </p>
  <p align="center">
    <img src="assets/mindmap.png">
</p>

  <p>
    To improve robustness under distribution shifts between heterogeneous data sources, Blackwall incorporates
    <strong>Domain Adversarial Training (DAT)</strong> to reduce domain-specific bias and encourage
    domain-invariant representations. In addition, we include a <strong>PAC-oriented evaluation and conditioning
    strategy</strong> to assess whether learned decision rules generalize consistently under standard learnability
    assumptions, supporting stable performance as data scale and domains vary.
  </p>

  <p>
     Overall, Blackwall aims to demonstrate how
    domain-robust and explainable AI can serve as a protective mechanism against unsafe or rogue behavior in
    intelligent systems, contributing to safer human–AI interaction while adhering to ethical and technical
    robustness requirements.
  </p>

</section>




