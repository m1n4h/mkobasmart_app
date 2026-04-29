document.addEventListener('DOMContentLoaded', () => {
    // Initial entrance animation
    gsap.from(".navbar", {
        y: -100,
        opacity: 0,
        duration: 1,
        ease: "power4.out"
    });

    gsap.from(".reveal", {
        y: 50,
        opacity: 0,
        duration: 1,
        stagger: 0.2,
        ease: "power3.out",
        delay: 0.5
    });

    // Mobile Menu Toggle logic
    const menuBtn = document.querySelector('.menu-btn');
    const navLinks = document.querySelector('.nav-links');

    menuBtn.addEventListener('click', () => {
        navLinks.classList.toggle('active');
        // Add CSS for .active class to show menu on mobile
    });
});
// Add ScrollTrigger to your GSAP animations
document.addEventListener('DOMContentLoaded', () => {
    
    // 1. Hero Animations (Run immediately)
    gsap.from(".hero-text .reveal", {
        y: 30,
        opacity: 0,
        duration: 0.8,
        stagger: 0.2,
        ease: "power2.out"
    });

    // 2. Feature Cards (Animate when they enter the viewport)
    // We use a simple Intersection Observer if you don't want to load a heavy plugin
    const observerOptions = {
        threshold: 0.2
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                // Trigger animation when the card scrolls into view
                gsap.to(entry.target, {
                    y: 0,
                    opacity: 1,
                    duration: 0.8,
                    ease: "power3.out"
                });
            }
        });
    }, observerOptions);

    // Set initial state for feature cards and observe them
    document.querySelectorAll('.feature-card').forEach(card => {
        gsap.set(card, { y: 50, opacity: 0 }); // Hide them initially
        observer.observe(card);
    });
});