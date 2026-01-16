/**
 * Onboarding Tutorial Component
 * Interactive tutorial for new users
 * THIRD PRIORITY: Critical for user retention
 */

import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './OnboardingTutorial.css';

const OnboardingTutorial = ({ onComplete }) => {
  const navigate = useNavigate();
  const [currentStep, setCurrentStep] = useState(0);

  const steps = [
    {
      id: 'welcome',
      title: 'Welcome to Meengle! ??',
      subtitle: 'Meet real people. Join real activities. Build real connections.',
      description:
        'Your all-in-one platform for discovering people and activities near you.',
      icon: '??',
      image: 'meengle-welcome',
      cta: 'Get Started',
    },
    {
      id: 'meegling',
      title: 'Meegling ??',
      subtitle: 'Swipe. Connect. Meet.',
      description:
        'Discover profiles based on your interests and location. Swipe right to like, left to skip. It\'s like Tinder but with personality and purpose.',
      icon: '??',
      image: 'meegling-demo',
      features: [
        '?? Send direct messages (Flame tier)',
        '?? Location-based discovery',
        '? Interest matching',
        '? Verified profiles',
      ],
      cta: 'Try Meegling',
    },
    {
      id: 'checkin',
      title: 'Check-Ins ??',
      subtitle: 'Connect with people nearby. Right now.',
      description:
        'Check in to your location (hotel, restaurant, event, etc.) and meet people at the same spot. Perfect for travelers and social butterflies.',
      icon: '??',
      image: 'checkin-demo',
      features: [
        '?? 15+ check-in types',
        '?? See who\'s nearby',
        '?? Message directly',
        '?? 5 status options',
      ],
      cta: 'Check In Nearby',
    },
    {
      id: 'activities',
      title: 'Activities ??',
      subtitle: 'Find things to do. Together.',
      description:
        'Discover or create activities (sports, yoga, food tours, gaming, etc.). Meet people through shared interests, not just attraction.',
      icon: '?',
      image: 'activities-demo',
      features: [
        '?? 20+ activity categories',
        '?? See participants before joining',
        '? Organizer ratings',
        '?? Recurring events',
      ],
      cta: 'Browse Activities',
    },
    {
      id: 'messages',
      title: 'Direct Messages ??',
      subtitle: 'Stay in touch. Make plans.',
      description:
        'Send direct messages to people you discover on profiles, check-ins, or activities. Real conversations, real connections.',
      icon: '??',
      image: 'messages-demo',
      features: [
        '? Instant messaging (Flame+)',
        '?? Video call requests',
        '?? Activity invitations',
        '? Read receipts',
      ],
      cta: 'Enable Messages',
      tier: 'flame',
    },
    {
      id: 'tiers',
      title: 'Choose Your Tier ?',
      subtitle: 'Unlock premium features.',
      description:
        'Free users can explore. Spark+ gets recommendations. Flame+ gets messaging. Wildfire gets everything.',
      icon: '??',
      image: 'tiers-demo',
      features: [
        '?? Free: Basic discovery',
        '? Spark+: Recommendations',
        '?? Flame: Direct messages',
        '?? Wildfire: All features',
      ],
      cta: 'View Pricing',
    },
    {
      id: 'ready',
      title: 'You\'re All Set! ??',
      subtitle: 'Single? Bored?... MEENGLE!',
      description:
        'Start discovering people and activities near you. The perfect match or experience is just a tap away.',
      icon: '?',
      image: 'ready-demo',
      cta: 'Go to Home',
      final: true,
    },
  ];

  const step = steps[currentStep];

  const handleNext = () => {
    if (currentStep < steps.length - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      completeOnboarding();
    }
  };

  const handleSkip = () => {
    completeOnboarding();
  };

  const completeOnboarding = () => {
    localStorage.setItem('onboardingComplete', 'true');
    if (onComplete) {
      onComplete();
    }
    navigate('/home');
  };

  const handlePrev = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    }
  };

  return (
    <div className="onboarding-container">
      <div className="onboarding-content">
        {/* Header */}
        <div className="onboarding-header">
          <button className="skip-btn" onClick={handleSkip}>
            Skip
          </button>
          <div className="progress-dots">
            {steps.map((_, index) => (
              <div
                key={index}
                className={`dot ${index === currentStep ? 'active' : ''}`}
              />
            ))}
          </div>
          <div style={{ width: '60px' }} /> {/* Spacer for alignment */}
        </div>

        {/* Step Content */}
        <div className="onboarding-step">
          {/* Icon */}
          <div className="step-icon">{step.icon}</div>

          {/* Title */}
          <h1 className="step-title">{step.title}</h1>

          {/* Subtitle */}
          <p className="step-subtitle">{step.subtitle}</p>

          {/* Description */}
          <p className="step-description">{step.description}</p>

          {/* Features List */}
          {step.features && (
            <div className="step-features">
              {step.features.map((feature, index) => (
                <div key={index} className="feature-item">
                  <span className="feature-check">?</span>
                  <span>{feature}</span>
                </div>
              ))}
            </div>
          )}

          {/* Illustration Placeholder */}
          <div className="step-image">{step.image}</div>

          {/* Tier Badge */}
          {step.tier && (
            <div className="tier-badge">{step.tier.toUpperCase()} tier feature</div>
          )}
        </div>

        {/* Navigation */}
        <div className="onboarding-nav">
          <button
            className="nav-btn prev"
            onClick={handlePrev}
            disabled={currentStep === 0}
          >
            ? Back
          </button>

          <button
            className="nav-btn next primary"
            onClick={handleNext}
          >
            {step.final ? 'Finish' : 'Next'}
            {!step.final && ' ?'}
          </button>
        </div>

        {/* Step Counter */}
        <div className="step-counter">
          Step {currentStep + 1} of {steps.length}
        </div>
      </div>
    </div>
  );
};

export default OnboardingTutorial;
