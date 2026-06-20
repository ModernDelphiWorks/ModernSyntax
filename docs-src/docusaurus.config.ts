import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'ModernSyntax',
  tagline: 'Functional programming toolkit and modern syntax extension for Delphi',
  favicon: 'img/favicon.svg',

  // Build output directory is set via CLI (`npm run build` → `docusaurus build --out-dir ../docs`)
  // so it stays compatible with Docusaurus 3 schema validation (top-level `outDir` is not allowed).

  url: 'https://moderndelphiworks.github.io',
  baseUrl: '/ModernSyntax/',
  organizationName: 'ModernDelphiWorks',
  projectName: 'ModernSyntax',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
          editUrl: undefined,
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    navbar: {
      title: 'ModernSyntax',
      logo: {
        alt: 'ModernSyntax Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Home',
        },
        {
          type: 'dropdown',
          label: 'Projects',
          position: 'left',
          items: [{ to: '/modernsyntax/', label: 'ModernSyntax' }],
        },
        {
          href: 'https://github.com/ModernDelphiWorks/ModernSyntax',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      copyright: `© ${new Date().getFullYear()} ModernSyntax — ModernDelphiWorks.`,
    },
    prism: {
      additionalLanguages: ['bash', 'json', 'powershell', 'pascal'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
