"""Run with: python -m unittest discover -s tests"""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class AgentSetupTest(unittest.TestCase):
    def test_links_preserve_harness_overrides_and_prune_only_owned_links(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            source = home / '.agents/skills'
            target = home / '.claude/skills'
            target.mkdir(parents=True)
            for name in ('shared', 'override', 'local'):
                skill = source / name
                skill.mkdir(parents=True)
                (skill / 'SKILL.md').write_text('skill\n')
            (target / 'override').symlink_to(home / 'private/override')
            (target / 'foreign-dead').symlink_to(home / 'private/missing')
            (target / 'alias').symlink_to(source / 'other-missing')
            (target / 'retired').symlink_to(source / 'retired')
            (target / 'local').mkdir()
            command = ['bash', str(ROOT / 'link-agent-skills.sh')]
            environment = {**os.environ, 'HOME': str(home)}
            subprocess.run(command + ['--dry-run', '--prune'], env=environment, check=True, capture_output=True)
            self.assertFalse((target / 'shared').exists())
            self.assertTrue((target / 'retired').is_symlink())
            self.assertEqual((target / 'alias').readlink(), source / 'other-missing')
            for _ in range(2):
                subprocess.run(command + ['--prune'], env=environment, check=True, capture_output=True)
                self.assertEqual((target / 'shared').readlink(), source / 'shared')
                self.assertEqual((target / 'override').readlink(), home / 'private/override')
                self.assertTrue((target / 'foreign-dead').is_symlink())
                self.assertEqual((target / 'alias').readlink(), source / 'other-missing')
                self.assertTrue((target / 'local').is_dir())
                self.assertFalse((target / 'retired').is_symlink())

    def test_shared_skills_and_pi_policy(self):
        skills = ROOT / 'agents/.agents/skills'
        self.assertFalse((skills / 'why').exists())
        for skill in skills.glob('*/SKILL.md'):
            text = skill.read_text()
            self.assertTrue(text.startswith('---\n'), skill)
            frontmatter = text.split('---', 2)[1]
            self.assertIn('name:', frontmatter, skill)
            self.assertIn('description:', frontmatter, skill)
            fences = sum(line.startswith('```') for line in text.splitlines())
            self.assertEqual(fences % 2, 0, skill)
            if 'disable-model-invocation: true' in frontmatter:
                metadata = skill.parent / 'agents/openai.yaml'
                self.assertIn('allow_implicit_invocation: false', metadata.read_text())
        settings = json.loads((ROOT / 'pi/.pi/agent/settings.json.example').read_text())
        roles = settings['subagents']['agentOverrides']
        for name in ('scout', 'reviewer'):
            self.assertEqual(roles[name]['tools'], ['read', 'grep', 'find', 'ls'])
        for role in roles.values():
            self.assertTrue(role['inheritGlobalContext'])
        self.assertEqual(roles['delegate']['thinking'], 'medium')
        self.assertEqual(settings['packages'][0]['extensions'], [])
        self.assertFalse((ROOT / 'agents/.agents/AGENTS.md').exists())
        for harness, name in [('pi/.pi/agent', 'AGENTS.md'), ('claude-code/.claude', 'CLAUDE.md'), ('codex/.codex', 'AGENTS.md')]:
            text = (ROOT / harness / name).read_text()
            self.assertNotIn('~/.agents/AGENTS.md', text)
            self.assertIn('ddev worktree <branch>', text)
            self.assertIn('Conventional Commits', text)


if __name__ == '__main__':
    unittest.main()
