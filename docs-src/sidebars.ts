import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    {
      type: 'doc',
      id: 'intro',
      label: 'Documentation portal',
    },
    {
      type: 'category',
      label: 'Projects',
      items: [{ type: 'link', label: 'ModernSyntax', href: '/modernsyntax/' }],
    },
  ],
  modernsyntaxSidebar: [
    {
      type: 'category',
      label: 'ModernSyntax',
      link: { type: 'doc', id: 'modernsyntax/index' },
      items: [
        'modernsyntax/introduction',
        {
          type: 'category',
          label: 'Getting Started',
          items: [
            'modernsyntax/getting-started/installation',
            'modernsyntax/getting-started/quickstart',
          ],
        },
        {
          type: 'category',
          label: 'Guides',
          items: [
            'modernsyntax/guides/null-safety',
            'modernsyntax/guides/pattern-matching',
            'modernsyntax/guides/railway-results',
            'modernsyntax/guides/functional-helpers',
          ],
        },
        {
          type: 'category',
          label: 'Reference',
          items: ['modernsyntax/reference/api-reference'],
        },
        {
          type: 'category',
          label: 'Troubleshooting',
          items: ['modernsyntax/troubleshooting/common-errors'],
        },
      ],
    },
  ],
};

export default sidebars;
