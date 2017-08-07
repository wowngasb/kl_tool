from setuptools import setup, find_packages

setup(name='gdom',
      version='0.1.1',
      download_url='git@github.com:syrusakbary/gdom.git',
      packages=find_packages(),
      author='Syrus Akbary',
      author_email='me@syrusakbary.com',
      description='DOM Traversing and Scraping using GraphQL',
      long_description=open('README.rst').read(),
      keywords='scraping html graphql json',
      url='http://github.com/syrusakbary/gdom',
      license='MIT',
      entry_points={
          'console_scripts': ['gdom = gdom.cmd:main']
      },
      install_requires=[
          'graphene>=1.0',
          'flask-graphql==1.2.0',
          'pyquery==1.2.11',
          'requests==2.9.1'
      ],
      tests_require=[
      ])
