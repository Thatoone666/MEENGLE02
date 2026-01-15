# Contributing to MEENGLE

Thank you for your interest in contributing to MEENGLE! This document provides guidelines and instructions for contributing.

## Getting Started

### 1. Fork and Clone
```bash
git clone https://github.com/YOUR_USERNAME/MEENGLE1.git
cd MEENGLE1
```

### 2. Create a Branch
```bash
git checkout -b feature/your-feature-name
# or for bug fixes:
git checkout -b bugfix/issue-description
```

### 3. Setup Development Environment
```bash
cd frontend
npm install
npm start
```

## Coding Standards

### JavaScript/React
- Use ES6+ syntax
- Follow existing code style
- Add JSDoc comments for functions
- Use meaningful variable names
- Keep components under 300 lines

### CSS
- Use CSS custom properties for colors
- Follow BEM naming convention
- Mobile-first responsive design
- Optimize for 60FPS animations
- Use `will-change` for animated elements

### File Structure
```
src/
??? components/          # Reusable UI components
?   ??? ComponentName.jsx
?   ??? ComponentName.css
??? pages/               # Page components
?   ??? PageName.jsx
?   ??? PageName.css
??? services/            # Business logic
?   ??? serviceName.js
??? config/              # Configuration files
??? styles/              # Global styles
    ??? designSystem.css
```

## Commit Messages

Format: `<type>: <description>`

Types:
- `feat:` New feature
- `fix:` Bug fix
- `refactor:` Code refactoring
- `style:` Styling changes
- `perf:` Performance improvement
- `docs:` Documentation
- `test:` Test additions
- `chore:` Dependency updates

Examples:
```
feat: Add video messaging support
fix: Resolve swipe animation lag on iOS
refactor: Simplify CheckInCard component
perf: Optimize image lazy loading
```

## Testing

### Run Tests
```bash
npm test
```

### Performance Testing
```bash
npm run build
npm run test:performance
```

### Accessibility Testing
- Use browser DevTools accessibility panel
- Test with keyboard navigation
- Verify color contrast (WCAG AA minimum)
- Test with screen reader

## Pull Request Process

### Before Submitting
1. ? Update your branch with latest main: `git pull origin main`
2. ? Run tests: `npm test`
3. ? Build project: `npm run build`
4. ? Check for console errors: `npm start` and open DevTools
5. ? Test responsiveness: Mobile, tablet, desktop

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## How Has This Been Tested?
- [ ] Unit tests
- [ ] Manual testing
- [ ] Device testing

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Tests pass
- [ ] No console errors
- [ ] Responsive on mobile
- [ ] Accessibility verified
- [ ] Documentation updated
```

## Code Review

- Be respectful and constructive
- Respond to feedback promptly
- Ask clarifying questions if needed
- Update PR based on feedback

## Performance Guidelines

- Maintain 60FPS animations
- Use CSS transforms for animations
- Implement lazy loading for images
- Keep bundle size minimal
- Debounce scroll/resize events

## Accessibility (WCAG AA)

- ? Color contrast ratio 4.5:1 for text
- ? Keyboard navigation support
- ? ARIA labels where appropriate
- ? Semantic HTML elements
- ? Focus visible states

## Feature Checklist

Before marking a feature complete:

- [ ] Component created/updated
- [ ] Styling applied (responsive)
- [ ] Error handling added
- [ ] Loading states implemented
- [ ] Tests written
- [ ] Accessibility verified
- [ ] Performance optimized
- [ ] Documentation updated
- [ ] Responsive tested
- [ ] Code reviewed

## Questions?

- ?? Create a GitHub Discussion
- ?? Open an issue for clarification
- ?? Comment on related PRs

## Code of Conduct

- Be respectful to all contributors
- Focus on the code, not the person
- Help new contributors
- Provide constructive feedback
- Report inappropriate behavior

---

**Thank you for contributing to MEENGLE! ??**
