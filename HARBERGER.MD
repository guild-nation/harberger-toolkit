# Implementation of Harberger Tax on Blockchain for Efficient Allocation of Scarce Resources

## Summary:

- This project aims to implement the economic policy of Harberger Tax, manipulated through smart contracts on a blockchain. Such an application could be used in conjunction with NFTs associated with a scarce resource, where creators seek to make the allocation as efficient as possible (RWA, access to online tools, token gating to courses, events), meaning the NFT would be in possession of the person who values it the most and can afford to pay to maintain its possession. The document delves into detail on what elements to consider for creating such an application.

## Introduction:

### Digital Scarcity and Ownership

The advent of blockchain technology and smart contracts has paved the way for the conceptualization of digital scarcity. Digital scarcity is defined as a credibly maintained limitation, imposed through software, on digital information, goods, or services that can be accessed and used entirely in a digital format. Specifically, in the context of Bitcoin, digital scarcity refers to the limitation on the total supply of bitcoin within the blockchain. This concept extends beyond mere quantity constraints, as evidenced by limitations on transaction throughput in the Bitcoin network, demonstrating digital scarcity as a multifaceted phenomenon.

In the digital realm, the ease of copying data, re-indexing databases, and altering variable values challenges the notion of maintaining digital data scarcity. However, establishing referential scarcity—where references are ledger/database entries—becomes feasible when credible assurances exist for maintaining scarcity and adhering to defined rules. Bitcoin's innovation and the introduction of blockchain as a decentralized ledger technology marked a significant milestone in achieving referential scarcity. With the emergence of advanced blockchain networks like Ethereum, the scope for scarce ledger entries expanded, giving rise to non-fungible tokens (NFTs).

NFTs represent a new class of unique digital items, ranging from claims of ownership over offline assets to purely digital collectibles. The rise of NFTs has spurred experiments with digital property, aiming not to restrict circulation and reproduction but to create value through titles and derivatives. This shift poses questions about the potential impact of distributed ledgers on economic dynamics, property rights, and financial speculation surrounding digital goods.
The combination of scarce resources managed through a public ledger, with the added capability of programmable actions enabled by smart contracts, opens up new possibilities in redefining traditional concepts of ownership.

### Ownership in a Digital Era:

Ownership is inherently a bundle of rights and duties, encompassing various entitlements and responsibilities. For instance, owning a car involves the right to drive it, prevent others from using it, sell or give it away, along with duties such as paying taxes and ensuring compliance with safety regulations. However, defining ownership in specific terms for various assets can be challenging, and the meaning of ownership may vary across different instances.

Without delving into philosophical debates on ownership, this document adopts the definition of ownership as "the act, state, or right of possessing something." This possession implies that the individual holding ownership will be subject to distinct rights and obligations associated with the possessed asset. The subsequent sections will elaborate on different classifications of ownership based on the rights and obligations contracted by the possessor.

## Proposing a New Framework for Ownership:

This project introduces a novel approach to defining ownership, leveraging the tools provided by the digital world, including technologies such as the public ledger known as blockchain and predefined programs called smart contracts. The application of these technologies aims to redefine the criteria for identifying ownership, offering a more transparent and programmable framework for managing rights and obligations associated with possessed assets.
By exploring the intersection of digital scarcity, ownership, and blockchain-based smart contracts, this research seeks to contribute to the evolving landscape of economic models and property rights in the digital era.

### Ownership Classifications:

#### Private, Public, and Common Ownership

Social or legal norms play a crucial role in determining the nature of ownership, with ownership often being conditional on government participation or group membership. In the context of government involvement, ownership is deemed public, while group membership leads to common ownership. If these norms don't apply, the default classification is private ownership.

In legal traditions such as Roman Law and the Common Law, privileged access to property is typically characterized by exclusivity and dominion. Exclusive access implies that a single individual holds the power to decide who can use and alienate the property, while dominion signifies that no restrictions are imposed by others regarding its use and alienation. These features, exclusive access and dominion, are considered essential components of private ownership.

**Challenges in the Legal Framework:**
Despite these traditional definitions, the legal framework encounters shortcomings that necessitate further consideration. Three notable issues include:

**Exclusive Dominion and External Restrictions:**
Exclusive dominion, a key aspect of private ownership, clashes with the fact that private ownership is often subject to taxes, eminent domain, and government regulations. While these attenuations don't transform private ownership into public or common ownership, they raise questions about the compatibility of exclusive dominion with external constraints. Corporate ownership, where no single individual holds exclusive dominion, also poses challenges in defining it as private ownership.
**Enforcement of Natural Law:**
The enforcement of natural law, which may regulate property relations, poses a mystery. It's unclear how natural law could ensure compliance independently of people's consent, given that individual motivations may not align with the dictates of natural law.

### Critiques of the different kinds of properties

**Critiques of Private Property:**
Critics highlight what we term the "monopoly problem," a concern broader than the conventional understanding. Traditionally, a monopolist is seen as an entity controlling the entire supply of a good to charge higher-than-market prices. However, in the context of landownership, a landowner can function as a monopolist by withholding supply for a generous offer. This approach may lead to underused or unused land, impacting allocative efficiency negatively. The capitalist system, despite radical reforms, has not entirely eliminated the barriers to the optimal use of land and labor, as monopoly power continues to hinder progress.

**Challenges with Common Property:**
Certain socialist critics believed that the perceived "irrationality" of capitalism could be addressed through state ownership and central planning. The rationale was that if the government owns all land and employs all citizens, it could efficiently order land improvement and optimal utilization. In this scenario, with a benevolent government operated by well-informed experts, the monopoly problem could be eliminated as no private entity would have the right to exclude others from the land. This central planning approach is often associated with the ideas of Karl Marx, although Marx eventually became skeptical of centralized planning, viewing it as susceptible to abuse.

However, despite the initial optimism surrounding central planning, it became evident that planning was essential not only to socialist utopias but also to capitalism itself. Social critics and economists alike grew frustrated with property owners obstructing economically valuable projects. The creation of large-scale enterprises, as noted by many economists, required coordinating various components, each controlled by a local monopolist. While corporate planning played a crucial role in overcoming local monopoly issues, it did not replace markets as the primary organizational method in the capitalist system.

**The Pitfalls of State or Group Ownership:**
Granting ownership of assets to the state or a select group ultimately leads to the individuals responsible for planning resource distribution becoming a form of monopolistic feudal lords. The trajectory, even with benevolent intentions, tends to result in concentration of power and authority, akin to the issues presented by private ownership. The concerns raised by Marx about centralized planning being prone to abuse find resonance in the realization that concentrating control in the hands of a few, whether in the private or public domain, poses inherent risks.

In practice, despite the potential advantages of state ownership and central planning in addressing certain issues, the challenges of concentration of power and the potential for abuse persist. The transition from one form of ownership to another does not guarantee the elimination of monopoly problems, as both private and centralized systems can face similar pitfalls. This underscores the complexity of finding an ideal system that balances efficiency, fairness, and accountability in the allocation and distribution of resources.

### Partial Common Ownership: A Revolutionary Approach

In the book "Radical Markets" by Eric Posner and Glen Weyl, a solution is proposed to address the inherent problems found in both private ownership capitalism and common ownership socialism. This solution, termed **"Partial Common Ownership"** or by its various acronyms such as SALSA, COST, and Harberger Tax, represents an extreme amalgamation of both systems, giving rise to the term "radical."

Based on the theories of George and the refined theory of Arnold Harberger, Partial Common Ownership is defined by Harberger as follows:
"If taxes are to be levied on the value of properties, it is important that assessment procedures be adopted which estimate the true economic value. The economist’s answer is simple: allow each owner to declare the value of his own property, make the declared values public, and require that an owner sell his property to any bidder willing to pay the declared value."

The key features of Partial Common Ownership include the transfer of two critical rights, the "right to use" and the "right to exclude," from the possessor to the public. This is achieved through a self-assessment tax system where property owners declare the value of their assets publicly and agree to sell the property to any bidder willing to pay the declared value.

**Right to Use:** A fraction of the use value is transferred to the public through the tax, encouraging optimal use of the property.

**Right to Exclude:** The owner loses the exclusive right to exclude others who offer to buy at the self-assessed price, allowing any member of the public to exclude the current owner by paying the assessed price.

Partial Common Ownership can be conceptualized as a shared ownership between society and the possessor, where possessors become lessees from society. This dynamic system encourages efficient allocation of resources without central planning. Unlike traditional central planning, the government does not set prices, allocate resources, or assign jobs. This approach combines extreme decentralization of power with partial socialization of ownership, creating a flexible market..

#### Benefits and Addressing Monopoly Problems:

Partial Common Ownership aims to address the myriad problems inhibiting privately owned assets from reaching their best use, often referred to as the "monopoly problem." It tackles issues like signaling, adverse selection, and the endowment effect, promoting efficient trade and resource utilization.

One of the key advantages is the mitigation of barriers to borrowing, allowing more people, especially those with limited cash resources, to engage in entrepreneurship or partial ownership without accumulating massive debt.

#### Balancing Investment Efficiency and Allocative Efficiency:

The concept of Partial Common Ownership represents a balance between investment efficiency and allocative efficiency. While traditional private property encourages investment efficiency, common ownership focuses on allocative efficiency. The proposed system optimizes both dimensions within a single property regime.

In the historical context, the evolution from feudalism to capitalism involved transforming communal land into private property, emphasizing allocative efficiency. However, a modern approach recognizes that forcing every form of property into extreme molds is inefficient. Partial Common Ownership emerges as a solution to balance the demands of investment and allocative efficiency within a dynamic and flexible market.

In summary, Partial Common Ownership challenges conventional notions of ownership, offering a revolutionary approach that optimizes resource allocation, encourages investment, and represents a significant departure from traditional models of capitalism and socialism.

## Conclusion

In summary, this exploration into the implementation of Harberger Tax on blockchain for the efficient allocation of scarce resources, particularly through NFT applications, lays the groundwork for a series of innovative experiments within the burgeoning financial ecosystem on blockchain platforms. The potential applications of this economic policy, as facilitated by smart contracts, extend across a wide range of scenarios—from real-world asset (RWA) ownership to exclusive access to digital services and events. This research represents merely the beginning of a broader initiative to harness blockchain's capabilities for fostering more efficient and equitable resource allocation.

The tools developed as part of this study are designed to simplify the process of experimentation, serving as a foundational step towards proposing enhancements to the Ethereum ecosystem through an Ethereum Improvement Proposal (EIP) in the near future. While specific use cases have been outlined in the documentation, the flexibility of the smart contracts allows for their application in a variety of innovative projects.

This endeavor is a call to action for developers, economists, and blockchain enthusiasts to engage in further experimentation and exploration of how Harberger Tax, when integrated with blockchain technology, can revolutionize our understanding and practice of asset ownership and management. As we move forward, it is essential to continue refining these models, ensuring they contribute positively to the evolving digital economy and help address some of the most pressing challenges in resource allocation and ownership.
